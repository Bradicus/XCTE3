##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'
require 'utils_base'
require 'types'
require 'code_elem_variable'
require 'code_elem_model'
require 'code_elem_var_group'

module XCTETypescript
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('typescript')
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      vDec = String.new
      typeName = String.new

      vDec << get_styled_variable_name(var)
      vDec << ': ' + getTypeName(var)

      vDec << '[]' if var.arrayElemCount.to_i > 0 && var.vtype != 'String'

      vDec << "\t/** " << var.comment << ' */' if !var.comment.nil?

      vDec
    end

    def addParamIfAvailable(params, var)
      return if var.nil?

      params.push('private ' + getParamDec(var))
    end

    def getParamDecForClass(cls, plug)
      pDec = String.new
      pDec << CodeNameStyling.getStyled(plug.get_unformatted_class_name(cls), @langProfile.variableNameStyle) << ': '

      pDec << plug.getClassName(cls)

      pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new
      typeName = String.new

      vDec << 'const ' if var.isConst

      vDec << 'static ' if var.isStatic

      vDec << get_styled_variable_name(var)
      vDec << ': ' + getTypeName(var)

      if !var.defaultValue.nil?
        if var.getUType.downcase == 'string'
          vDec << ' = "' << var.defaultValue << '"'
        else
          vDec << ' = ' << var.defaultValue << ''
        end
      elsif var.getUType.downcase == 'string'
        vDec << ' = ""'
      elsif var.getUType.downcase == 'boolean'
        vDec << ' = false'
      elsif Types.instance.inCategory(var, 'time')
        vDec << ' = new Date()'
      elsif var.isList
        vDec << ' = []'
      elsif !is_primitive(var)
        vDec << ' = new ' + CodeNameStyling.getStyled(var.getUType, @langProfile.classNameStyle) + '()'
      else
        vDec << ' = 0'
      end

      vDec << ';'

      vDec << "\t/** " << var.comment << ' */' if !var.comment.nil?

      vDec
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      'ARRAYSZ_' << var.name.upcase
    end

    # Get a type name for a variable
    def getTypeName(var)
      typeName = getSingleItemTypeName(var)

      typeName = apply_template(var.templates[0], typeName) if var.isList

      typeName
    end

    def getSingleItemTypeName(var)
      typeName = getBaseTypeName(var)

      singleTpls = var.templates
      singleTpls = singleTpls.drop(1) if var.isList

      for tpl in singleTpls.reverse
        typeName = apply_template(tpl, typeName)
      end

      typeName
    end

    def apply_template(tpl, curTypeName)
      tplType = @langProfile.getTypeName(tpl.name)
      if tpl.name.downcase == 'list'
        typeName = curTypeName + '[]'
      else
        typeName = tplType + '<' + curTypeName + '>'
      end

      typeName
    end

    # Return the language type based on the generic type
    def getBaseTypeName(var)
      nsPrefix = ''

      baseTypeName = ''
      if !var.vtype.nil?
        baseTypeName = @langProfile.getTypeName(var.vtype)
      else
        baseTypeName = CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end

      nsPrefix + baseTypeName
    end

    def getListTypeName(listTypeName)
      @langProfile.getTypeName(listTypeName)
    end

    # Get the extension for a file type
    def getExtension(eType)
      @langProfile.getExtension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      '/* ' << var.text << " */\n"
    end

    # Capitalizes the first letter of a string
    def getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      newStr += str[1..str.length - 1] if str.length > 1

      newStr
    end

    # process variable group
    def renderReactiveFormGroup(cls, bld, _vGroup, isDisabled, separator = ';')
      bld.sameLine('new FormGroup({')
      bld.indent

      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if is_primitive(var)
          hasMult = var.isList
          if !var.isList
            bld.add(genPrimitiveFormControl(var, isDisabled) + ',')
          else
            bld.add(get_styled_variable_name(var) + ': new FormArray([]),')
          end
        else
          otherClass = ClassModelManager.findVarClass(var, 'standard')

          if !var.isList
            if !otherClass.nil?
              if !var.selectFrom.nil?
                bld.add(get_styled_variable_name(var, '', ' id') + ': ')
                idVar = cls.model.getIdentityVar
                bld.sameLine(getFormcontrolType(idVar, idVar.getUType, '', isDisabled) + ',')
              else
                bld.add(get_styled_variable_name(var) + ': ')
                renderReactiveFormGroup(otherClass, bld, otherClass.model.varGroup, isDisabled, ',')
              end
            else
              bld.add(get_styled_variable_name(var) + ': ')
              bld.sameLine("new FormControl(''),")
            end
          else
            bld.add(get_styled_variable_name(var) + ': new FormArray([]),')
          end
        end
      }))

      bld.unindent
      bld.add('})' + separator)
    end

    def genPrimitiveFormControl(var, isDisabled)
      validators = []
      validators << 'Validators.required' if var.required
      validators << 'Validators.maxLength(' + var.arrayElemCount.to_s + ')' if var.arrayElemCount > 0

      vdString = ''
      if !validators.empty?
        vdString = ', [' + validators.join(', ') + ']'
      end

      get_styled_variable_name(var) + ': ' + getFormcontrolType(var, vdString, isDisabled)
    end

    def getFormcontrolType(var, vdString, isDisabled)
      utype = var.getUType.downcase
      if utype.start_with?('date')
        if !isDisabled
          return 'new FormControl<Date>(new Date()' + vdString + ')'
        else
          return 'new FormControl<Date>({value: new Date(), disabled: true}' + vdString + ')'
        end
      end

      if Types.instance.inCategory(var, 'text') || utype == 'guid'
        if !isDisabled
          return 'new FormControl<' + getBaseTypeName(var) + ">(''" + vdString + ')'
        else
          return 'new FormControl<' + getBaseTypeName(var) + ">({value: '', disabled: true}" + vdString + ')'
        end
      elsif utype == 'boolean'
        if !isDisabled
          return 'new FormControl<' + getBaseTypeName(var) + '>(false)'
        else
          return 'new FormControl<' + getBaseTypeName(var) + '>({value: false, disabled: true})'
        end
      end

      if isDisabled
        return 'new FormControl<' + getBaseTypeName(var) + '>({value: 0, disabled: true}' + vdString + ')'
      end

      return 'new FormControl<' + getBaseTypeName(var) + '>(0' + vdString + ')'
    end

    def getStyledUrlName(name)
      CodeNameStyling.getStyled(name, 'DASH_LOWER')
    end

    def addClassnamesFor(clsList, otherClasses, language, classType)
      for otherCls in otherClasses
        if otherCls.plugName == classType
          plug = XCTEPlugin.findClassPlugin(language, classType)
          clsList.push(plug.getClassName(otherCls))
        end
      end
    end

    def getStyledPageName(var); end

    def renderClassList(clsList, bld)
      firstLine = true
      uniqueList = clsList.uniq

      for c in uniqueList
        bld.sameLine(',') if !firstLine

        bld.iadd(c)
        firstLine = false
      end
    end

    def getRelatedClasses(cls)
      relClasses = []

      if !cls.model.featureGroup.nil?
        fClasses = ClassModelManager.findFeatureClasses(cls.model.featureGroup)

        for otherCls in fClasses
          relClasses.push(otherCls)
        end
      end

      for otherCls in cls.model.classes
        relClasses.push(otherCls)
      end

      relClasses.uniq
    end

    def getOptionsVarFor(var)
      optVar = var.clone
      optVar.name = var.selectFrom + ' options'
      optVar.utype = var.selectFrom
      optVar.vtype = nil
      optVar.relation = nil
      optVar.defaultValue = 'new Observable<FilteredPageRespTpl<' + get_styled_class_name(optVar.utype) + '>>'
      optVar.templates = []
      optVar.addTpl('Observable')
      optVar.addTpl('FilteredPageRespTpl', true)

      optVar
    end

    def getOptionsReqVarFor(var)
      optVar = var.clone
      optVar.name = var.selectFrom + ' options req'
      optVar.utype = var.selectFrom
      optVar.vtype = nil
      optVar.defaultValue = 'new FilteredPageReqTpl<' + get_styled_class_name(optVar.utype) + '>'
      optVar.templates = []
      optVar.addTpl('FilteredPageReqTpl', true)

      optVar
    end

    def get_search_fun(_cls, searchColNames)
      fun = CodeStructure::CodeElemFunction.new(nil)

      colNameCointain = []
      pageVar = CodeStructure::CodeElemVariable.new(nil)
      pageVar.name = 'pageRequest'
      pageVar.vtype = 'PageRequest'
      fun.add_param(pageVar)

      for col in searchColNames
        colNameCointain.push(get_styled_class_name(col))
      end

      eventVar = CodeStructure::CodeElemVariable.new(nil)
      eventVar.name = 'event'
      eventVar.vtype = 'any'
      fun.add_param(eventVar)

      fun.name = 'onSearchBy' + colNameCointain.join('Or')

      fun
    end

    def get_search_var(_cls, searchColNames)
      fun = CodeStructure::CodeElemFunction.new(nil)

      colNameCointain = []
      pageVar = CodeStructure::CodeElemVariable.new(nil)
      pageVar.name = 'pageRequest'
      pageVar.vtype = 'PageRequest'
      fun.add_param(pageVar)

      for col in searchColNames
        colNameCointain.push(get_styled_class_name(col))
      end

      eventVar = CodeStructure::CodeElemVariable.new(nil)
      eventVar.name = 'event'
      eventVar.vtype = 'any'
      fun.add_param(eventVar)

      fun.name = 'search' + colNameCointain.join('Or')

      fun
    end

    def get_search_subject(search)
      colNameCointain = []
      for col in search.columns
        colNameCointain.push(get_styled_class_name(col))
      end

      subjectVar = CodeStructure::CodeElemVariable.new(nil)
      subjectVar.name = 'search' + colNameCointain.join('Or') + 'Subject'
      subjectVar.vtype = 'BehaviorSubject<string>'
      subjectVar.defaultValue = "''"

      subjectVar
    end
  end
end
