##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile"
require "utils_base"
require "types"
require "code_structure/code_elem_variable"
require "code_structure/code_elem_model"
require "code_structure/code_elem_var_group"

module XCTETypescript
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("typescript")
    end

    # Get a parameter declaration for a method parameter
    def get_param_dec(var)
      vDec = String.new
      typeName = String.new

      if !var.visibility.nil? && var.visibility == "private"
        vDec << var.visibility << " "
      end

      vDec << get_styled_variable_name(var)
      vDec << ": " + get_type_name(var)

      vDec << "[]" if var.arrayElemCount.to_i > 0 && var.vtype != "String"

      vDec << "\t/** " << var.comment << " */" if !var.comment.nil?

      vDec
    end

    def add_param_if_available(params, var)
      return if var.nil?
      params.push var
    end

    def get_param_dec_for_class(cls, plug)
      pDec = String.new
      pDec << CodeNameStyling.getStyled(plug.get_unformatted_class_name(cls), @langProfile.variableNameStyle) << ": "

      pDec << plug.get_class_name(cls)

      pDec
    end

    # Returns variable declaration for the specified variable
    def get_var_dec(var)
      vDec = String.new
      typeName = String.new

      vDec << "const " if var.isConst

      vDec << "static " if var.isStatic

      vDec << get_styled_variable_name(var)

      vDec << ": " + get_type_name(var)

      if !var.defaultValue.nil?
        if var.getUType.downcase == "string"
          vDec << ' = "' << var.defaultValue << '"'
        else
          vDec << " = " << var.defaultValue << ""
        end
      elsif var.init_vars
        if var.isList
          vDec << " = []"
        elsif var.getUType.downcase == "string"
          if var.nullable
            vDec << " = null"
          else
            vDec << ' = ""'
          end
        elsif var.getUType.downcase == "boolean"
          vDec << " = false"
        elsif Types.instance.inCategory(var, "time")
          vDec << " = new Date()"
        elsif !is_primitive(var)
          vDec << " = new " + CodeNameStyling.getStyled(var.getUType, @langProfile.classNameStyle) + "()"
        else
          vDec << " = 0"
        end
      end

      vDec << ";"

      vDec << "\t/** " << var.comment << " */" if !var.comment.nil?

      vDec
    end

    # Returns a size constant for the specified variable
    def get_size_const(var)
      "ARRAYSZ_" << var.name.upcase
    end

    # Get a type name for a variable
    def get_type_name(var)
      typeName = get_single_item_type_name(var)

      if var.isList
        typeName = apply_template(var.templates[0], typeName)
      end

      if var.nullable
        typeName += " | null"
      end

      return typeName
    end

    def get_single_item_type_name(var)
      typeName = get_base_type_name(var)

      singleTpls = var.templates
      singleTpls = singleTpls.drop(1) if var.isList

      for tpl in singleTpls.reverse
        typeName = apply_template(tpl, typeName)
      end

      typeName
    end

    def apply_template(tpl, curTypeName)
      tplType = @langProfile.get_type_name(tpl.name)
      if tpl.name.downcase == "list"
        typeName = curTypeName + "[]"
      else
        typeName = tplType + "<" + curTypeName + ">"
      end

      typeName
    end

    # Return the language type based on the generic type
    def get_base_type_name(var)
      nsPrefix = ""

      baseTypeName = ""
      if !var.vtype.nil?
        baseTypeName = @langProfile.get_type_name(var.vtype)
      else
        baseTypeName = CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end

      nsPrefix + baseTypeName
    end

    def get_list_type_name(listTypeName)
      @langProfile.get_type_name(listTypeName)
    end

    # Get the extension for a file type
    def get_extension(eType)
      @langProfile.get_extension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def get_comment(var)
      "/* " << var.text << " */\n"
    end

    # Capitalizes the first letter of a string
    def get_capitalized_first(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      newStr += str[1..str.length - 1] if str.length > 1

      newStr
    end

    # process variable group
    def render_reactive_form_group(cls, bld, _vGroup, isDisabled, separator = ";")
      bld.same_line("new FormGroup({")
      bld.indent

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if is_primitive(var)
          hasMult = var.isList
          if !var.isList
            bld.add(gen_primitive_form_control(var, isDisabled) + ",")
          else
            bld.add(get_styled_variable_name(var) + ": new FormArray([]),")
          end
        else
          otherClass = ClassModelManager.findVarClass(var, "class_standard")

          if !var.isList
            if !otherClass.nil?
              if !var.selectFrom.nil?
                bld.add(get_styled_variable_name(var, "", " id") + ": ")
                idVar = cls.model.getIdentityVar
                bld.same_line(get_form_control_type(idVar, idVar.getUType, "", isDisabled) + ",")
              else
                bld.add(get_styled_variable_name(var) + ": ")
                render_reactive_form_group(otherClass, bld, otherClass.model.varGroup, isDisabled, ",")
              end
            else
              bld.add(get_styled_variable_name(var) + ": ")
              bld.same_line("new FormControl(''),")
            end
          else
            bld.add(get_styled_variable_name(var) + ": new FormArray([]),")
          end
        end
      }))

      bld.unindent
      bld.add("})" + separator)
    end

    def gen_primitive_form_control(var, isDisabled)
      validators = []
      validators << "Validators.required" if var.required
      validators << "Validators.maxLength(" + var.arrayElemCount.to_s + ")" if var.arrayElemCount > 0

      vdString = ""
      if !validators.empty?
        vdString = ", [" + validators.join(", ") + "]"
      end

      get_styled_variable_name(var) + ": " + get_form_control_type(var, vdString, isDisabled)
    end

    def get_form_control_type(var, vdString, isDisabled)
      utype = var.getUType.downcase
      if utype.start_with?("date")
        if !isDisabled
          return "new FormControl<Date>(new Date()" + vdString + ")"
        else
          return "new FormControl<Date>({value: new Date(), disabled: true}" + vdString + ")"
        end
      end

      if Types.instance.inCategory(var, "text") || utype == "guid"
        if !isDisabled
          return "new FormControl<" + get_base_type_name(var) + ">(''" + vdString + ")"
        else
          return "new FormControl<" + get_base_type_name(var) + ">({value: '', disabled: true}" + vdString + ")"
        end
      elsif utype == "boolean"
        if !isDisabled
          return "new FormControl<" + get_base_type_name(var) + ">(false)"
        else
          return "new FormControl<" + get_base_type_name(var) + ">({value: false, disabled: true})"
        end
      end

      if isDisabled
        return "new FormControl<" + get_base_type_name(var) + ">({value: 0, disabled: true}" + vdString + ")"
      end

      return "new FormControl<" + get_base_type_name(var) + ">(0" + vdString + ")"
    end

    def get_styled_url_name(name)
      CodeNameStyling.getStyled(name, "DASH_LOWER")
    end

    def add_class_names_for(clsList, otherClasses, language, classType)
      for otherCls in otherClasses
        if otherCls.plug_name == classType
          plug = XCTEPlugin.findClassPlugin(language, classType)
          clsList.push(plug.get_class_name(otherCls))
        end
      end
    end

    def get_styled_page_name(var); end

    def render_class_list(clsList, bld)
      firstLine = true
      uniqueList = clsList.uniq

      for c in uniqueList
        bld.same_line(",") if !firstLine

        bld.iadd(c)
        firstLine = false
      end
    end

    def get_related_classes(cls)
      relClasses = []

      if !cls.model.feature_group.nil?
        fClasses = ClassModelManager.findFeatureClasses(cls.model.feature_group)

        for otherCls in fClasses
          relClasses.push(otherCls)
        end
      end

      for otherCls in cls.model.classes
        relClasses.push(otherCls)
      end

      relClasses.uniq
    end

    def get_options_var_for(var)
      optVar = var.clone
      optVar.name = var.selectFrom + " options"
      optVar.utype = var.selectFrom
      optVar.vtype = nil
      optVar.relation = nil
      optVar.defaultValue = "new Observable<FilteredPageRespTpl<" + style_as_class(optVar.utype) + ">>"
      optVar.templates = []
      optVar.addTpl("Observable")
      optVar.addTpl("FilteredPageRespTpl", true)

      optVar
    end

    def get_options_req_var_for(var)
      optVar = var.clone
      optVar.name = var.selectFrom + " options req"
      optVar.utype = var.selectFrom
      optVar.vtype = nil
      optVar.defaultValue = "new FilteredPageReqTpl<" + style_as_class(optVar.utype) + ">"
      optVar.templates = []
      optVar.addTpl("FilteredPageReqTpl", true)

      optVar
    end

    def get_search_fun(_cls, searchColNames)
      fun = CodeStructure::CodeElemFunction.new(nil)

      colNameCointain = []
      pageVar = CodeStructure::CodeElemVariable.new(nil)
      pageVar.name = "pageRequest"
      pageVar.vtype = "PageRequest"
      fun.add_param(pageVar)

      for col in searchColNames
        colNameCointain.push(style_as_class(col))
      end

      eventVar = CodeStructure::CodeElemVariable.new(nil)
      eventVar.name = "event"
      eventVar.vtype = "any"
      fun.add_param(eventVar)

      fun.name = "onSearchBy" + colNameCointain.join("Or")

      fun
    end

    def get_search_var(_cls, searchColNames)
      fun = CodeStructure::CodeElemFunction.new(nil)

      colNameCointain = []
      pageVar = CodeStructure::CodeElemVariable.new(nil)
      pageVar.name = "pageRequest"
      pageVar.vtype = "PageRequest"
      fun.add_param(pageVar)

      for col in searchColNames
        colNameCointain.push(style_as_class(col))
      end

      eventVar = CodeStructure::CodeElemVariable.new(nil)
      eventVar.name = "event"
      eventVar.vtype = "any"
      fun.add_param(eventVar)

      fun.name = "search" + colNameCointain.join("Or")

      fun
    end

    def get_search_subject(search)
      subjectVar = CodeStructure::CodeElemVariable.new(nil)
      subjectVar.name = search.get_name + " subject"
      subjectVar.vtype = "BehaviorSubject<string>"
      subjectVar.defaultValue = "''"

      subjectVar
    end

    def get_search_subject_var(col)
      subjectVar = CodeStructure::CodeElemVariable.new(nil)
      subjectVar.name = col + " subject"
      subjectVar.vtype = "BehaviorSubject<string>"
      subjectVar.defaultValue = "''"

      subjectVar
    end
  end
end
