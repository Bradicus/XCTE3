##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'
require 'utils_base'
require 'log'
require 'ref_finder'
require 'plugins_core/lang_tsql/utils'

module XCTEJava
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('java')
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << getTypeName(var)

      pDec << ' ' << get_styled_variable_name(var)

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new

      vDec << var.visibility << ' '

      vDec << 'const ' if var.isConst

      vDec << 'static ' if var.isStatic

      vDec << 'virtual ' if var.isVirtual

      vDec << getTypeName(var)

      vDec << ' '

      vDec << '?' if var.nullable

      vDec << get_styled_variable_name(var)
      vDec << ';'

      vDec << "\t/** " << var.comment << ' */' if !var.comment.nil?

      return vDec
    end

    # def getFullType(var)
    #   fType = ""

    #   if (var.templateType != nil)
    #     fType << var.templateType << "<" << self.getTypeName(var) << ">"
    #   elsif (var.listType != nil)
    #     fType << var.listType << "<" << self.getTypeName(var) << ">"
    #   else
    #     fType << self.getTypeName(var)
    #   end
    # end

    def getFullOjbType(var)
      fType = ''

      if !var.templateType.nil?
        fType += var.templateType + '<' + getTypeName(var) + '>'
      elsif !var.listType.nil?
        fType += var.listType + '<' + getTypeName(var) + '>'
      else
        fType += getTypeName(var)
      end
    end

    # Return the language type based on the generic type
    def getTypeName(var)
      typeName = getSingleItemTypeName(var)

      if var.templates.length > 0 && var.templates[0].isCollection
        tplType = @langProfile.getTypeName(var.templates[0].name)
        typeName = tplType + '<' + typeName + '>'
      end

      return typeName
    end

    def getSingleItemTypeName(var)
      typeName = getBaseTypeName(var)

      singleTpls = var.templates
      if singleTpls.length > 0 && singleTpls[0].isCollection
        singleTpls = singleTpls.drop(1)

        typeName = getObjTypeName(var) if isPrimitive(var)
      end

      for tpl in singleTpls.reverse
        typeName = tpl.name + '<' + typeName + '>'
      end

      return typeName.strip
    end

    # Return the language type based on the generic type
    def getBaseTypeName(var)
      nsPrefix = ''
      langType = @langProfile.getTypeName(var.getUType)

      if !var.utype.nil? # Only unformatted name needs styling
        baseTypeName = CodeNameStyling.getStyled(langType, @langProfile.classNameStyle)
      else
        baseTypeName = langType
      end

      # if var.namespace.hasItems?()
      #   nsPrefix = var.namespace.get("::") + "::"
      #   baseTypeName = nsPrefix + baseTypeName
      # end

      return baseTypeName
    end

    # Return the language type based on the generic type
    def getObjTypeName(var)
      return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle) if var.vtype.nil?

      objType = getType(var.vtype + 'obj')
      return objType.langType if !objType.nil?

      return @langProfile.getTypeName(var.vtype)
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return CodeNameStyling.getStyled('max len ' + var.name, @langProfile.constNameStyle)
    end

    # Get the extension for a file type
    def getExtension(eType)
      return @langProfile.getExtension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return '/* ' << var.text << " */\n"
    end

    # Capitalizes the first letter of a string
    def getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      newStr += str[1..str.length - 1] if str.length > 1

      return(newStr)
    end

    def getStyledUrlName(name)
      return CodeNameStyling.getStyled(name, 'DASH_LOWER')
    end

    def process_var_dependencies(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE && !isPrimitive(var)
          varCls = ClassModelManager.findVarClass(var)
          fPath = getStyledFileName(var.getUType + '')
          cls.addInclude(varCls.path + '/' + fPath + '.module', get_styled_class_name(var.getUType + ' module'))
        end
      end

      for grp in vGroup.varGroups
        process_var_dependencies(cls, bld, grp)
      end
    end

    def requires_var(cls, var)
      # varClass = ClassModelManager.findVarClass(var)
      varClassAndPlug = RefFinder.find_class_by_type(cls.genCfg.language, var.getUType)
      # requires_other_class_type(cls, varClass, varClass.plug.name)

      return unless !varClassAndPlug.nil? && !cls.namespace.same?(varClassAndPlug.cls.namespace)

      cls.addUse(varClassAndPlug.cls.namespace.get('.') + '.*')
    end

    def requires_other_class_type(cls, _otherCls, plugName)
      plugNameClass = cls.model.findClassModelByPluginName(plugName)
      return if cls.namespace.same?(plugNameClass.namespace)

      cls.addUse(plugNameClass.namespace.get('.') + '.*')
    end

    def requires_class_type(cls, fromCls, plugName)
      plugNameClass = fromCls.model.findClassModelByPluginName(plugName)

      if plugNameClass.nil?
        Log.error('unable to find class by type ' + plugName)
      elsif plugNameClass.namespace.nsList.length == 0
        throw 'Zero length namespace'
      else
        cls.addUse(plugNameClass.namespace.get('.') + '.*')
      end
    end

    def requires_class_ref(cls, classRef)
      plugNameClass = ClassModelManager.findClass(classRef.className, classRef.pluginName)

      if plugNameClass.nil?
        Log.error('unable to find class by ref ')
      else
        cls.addUse(plugNameClass.namespace.get('.') + '.*')
      end
    end

    def get_data_class(cls)
      if !cls.dataClass.nil?
        dataClass = ClassModelManager.findClass(cls.dataClass.className, cls.dataClass.pluginName)
        return dataClass if !dataClass.nil?
      end

      return cls
    end

    def add_class_injection(toCls, fromCls, plugName)
      varClass = fromCls.model.findClassModelByPluginName(plugName)
      if !varClass.nil?
        var = createVarFor(varClass, plugName)
        var.visibility = 'private'

        if !var.nil?
          toCls.addInjection(var)
          requires_var(toCls, var)
        end
      else
        Log.error('Unable to find class type ' + plugName + ' for model ' + fromCls.model.name)
      end
    end

    def get_search_fun(cls, searchColNames)
      fun = CodeStructure::CodeElemFunction.new(nil)

      if !cls.dataClass.nil?
        dataClass = ClassModelManager.findClass(cls.dataClass.className, cls.dataClass.pluginName)
        pageReqVar = createVarFor(dataClass, dataClass.plugName)
      else
        dataClass = cls
        pageReqVar = createVarFor(dataClass, 'class_jpa_entity')
      end

      throw('could not find class_jpa_entity for ' + dataClass.model.name) if pageReqVar.nil?

      pageReqVar.templates.push(CodeStructure::CodeElemTemplate.new('Page'))
      fun.returnValue = pageReqVar

      colNameCointain = []
      pageVar = CodeStructure::CodeElemVariable.new(nil)
      pageVar.name = 'pageRequest'
      pageVar.vtype = 'PageRequest'
      fun.add_param(pageVar)

      if cls.model.data_filter.static_filter.nil?
        for col in searchColNames
          colVar = dataClass.model.getFilteredVars(->(var) { var.name == col })

          throw('Could not find column variable named ' + col) if colVar.empty?

          colNameCointain.push(get_styled_class_name(col) + 'Contains')
          fun.add_param(colVar[0])
        end

        fun.name = 'findBy' + colNameCointain.join('Or')
      elsif cls.model.data_filter.search.columns.length > 0
        tableVar = CodeNameStyling.getStyled(dataClass.model.name, XCTETSql::Utils.instance.langProfile.variableNameStyle)
        talbeName = CodeNameStyling.getStyled(dataClass.model.name, XCTETSql::Utils.instance.langProfile.classNameStyle)
        query = 'SELECT ' + tableVar + ' FROM ' + talbeName
        query += ' WHERE ' + tableVar + '.' + cls.model.data_filter.static_filter.column + ' = '
        query += cls.model.data_filter.static_filter.value

        if searchColNames.length > 0
          searchCompares = []
          for col in searchColNames
            searchCompares.push(get_styled_class_name(col) + "LIKE '%:searchValue%")
          end

          query += ' AND (' + searchCompares.join(' OR ') + ')'
        end

        fun.annotations.push('@Query("' + query + '")')
        fun.name = 'findBy' + get_styled_class_name(cls.model.data_filter.static_filter.column)
      else # Statif filter but no search filter
        fun.name = 'findBy' + get_styled_class_name(cls.model.data_filter.static_filter.column)
      end

      return fun
    end

    def render_fun_call(_bld, _fun)
      return getStyledFunctionName(col) + '(' + ')'
    end
  end
end
