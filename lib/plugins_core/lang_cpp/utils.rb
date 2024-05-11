##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains the language profile for C++ and utility fuctions
# used by various plugins

require "code_name_styling"
require "utils_base"
require "singleton"

module XCTECpp
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("cpp")
    end

    # Get a parameter declaration for a method parameter
    def get_param_dec(var)
      pDec = String.new

      pDec += "const " if var.isConst

      pDec += get_type_name(var)

      pDec += "&" if var.passBy.upcase == "REFERENCE"
      pDec += "*" if var.isPointer

      pDec += " " + get_styled_variable_name(var)

      pDec += "[]" if var.arrayElemCount > 0

      return pDec
    end

    # Returns variable declaration for the specified variable
    def get_var_dec(var)
      vDec = String.new
      typeName = String.new

      vDec += "const " if var.isConst

      vDec += "static " if var.isStatic

      vDec += get_type_name(var)

      vDec += "*" if var.isPointer

      vDec += "&" if var.passBy.upcase == "REFERENCE"

      vDec += " " + get_styled_variable_name(var)

      vDec += "[" + get_size_const(var) + "]" if var.arrayElemCount.to_i > 0

      vDec += ";"

      vDec += "\t/** " + var.comment + " */" if !var.comment.nil?

      return vDec
    end

    # Returns a size constant for the specified variable
    def get_size_const(var)
      return "ARRAYSZ_" + var.name.upcase
    end

    # Capitalizes the first letter of a string
    def get_capitalized_first(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      newStr += str[1..str.length - 1] if str.length > 1

      return(newStr)
    end

    def get_class_ref_type(cls, cls_ref)
      typeName = ""

      if cls_ref.namespace.hasItems?
        typeName += cls_ref.namespace.get("::") + "::"
      end

      bc_sap = get_plugin_and_spec_for_ref(cls, cls_ref)

      if bc_sap.valid?
        typeName += bc_sap.plugin.get_class_name(bc_sap.spec)
      else # If this class isn't made by us
        typeName += style_as_class(cls_ref.model_name)
      end

      if cls_ref.template_params.length > 0
        typeName += "<" + cls_ref.get_template_param_names().join(", ") + ">"
      end

      return typeName
    end

    # Return the language type based on the generic type
    def get_type_name(var)
      typeName = get_single_item_type_name(var)

      if var.templates.length > 0 && var.templates[0].isCollection
        tplType = @langProfile.get_type_name(var.templates[0].name)
        typeName = tplType + "<" + typeName + ">"
      end

      return typeName
    end

    def get_single_item_type_name(var)
      typeName = get_base_type_name(var)

      singleTpls = var.templates
      singleTpls = singleTpls.drop(1) if singleTpls.length > 0 && singleTpls[0].isCollection

      for tpl in singleTpls.reverse
        typeName = tpl.name + "<" + typeName + ">"
      end

      return typeName.strip
    end

    # Return the language type based on the generic type
    def get_base_type_name(var)
      nsPrefix = ""
      langType = @langProfile.get_type_name(var.getUType)

      if !var.utype.nil? # Only unformatted name needs styling
        baseTypeName = CodeNameStyling.getStyled(langType, @langProfile.classNameStyle)
      else
        baseTypeName = langType
      end

      if var.namespace.hasItems?
        nsPrefix = var.namespace.get("::") + "::"
        baseTypeName = nsPrefix + baseTypeName
      end

      return baseTypeName
    end

    def get_class_name(var)
      return @langProfile.get_type_name(var.vtype) if !var.vtype.nil?

      return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
    end

    def getClassTypeName(cls)
      nsPrefix = ""
      nsPrefix = cls.namespace.get("::") + "::" if cls.namespace.hasItems?

      baseTypeName = CodeNameStyling.getStyled(cls.model_name, @langProfile.classNameStyle)
      baseTypeName = nsPrefix + baseTypeName

      if cls.template_params.length > 0
        allParams = []

        for param in cls.template_params
          allParams.push(CodeNameStyling.getStyled(param.name, @langProfile.classNameStyle))
        end

        baseTypeName += "<" + allParams.join(", ") + ">"
      end

      return baseTypeName
    end

    def getDerivedClassPrefix(cls_ref)
      tplNames = []

      if cls_ref.is_a? CodeStructure::CodeElemClassRef
        name = cls_ref.model_name
      else
        name = cls_ref.model.name
      end

      for tplParam in cls_ref.template_params
        tplNames.push(tplParam.model_name)
      end

      prefix = CodeNameStyling.getStyled(name, @langProfile.classNameStyle) + tplNames.join("")

      return prefix
    end

    def get_list_type_name(listTypeName)
      return @langProfile.get_type_name(listTypeName)
    end

    def get_comment(var)
      return "/* " + var.text + " */\n"
    end

    def getZero(var)
      return "0.0f" if var.vtype == "Float32"
      return "0.0" if var.vtype == "Float64"

      return "0"
    end

    def getDataListInfo(classXML)
      dInfo = {}

      classXML.elements.each("DATA_LIST_TYPE") do |dataListXML|
        dInfo["cppTemplateType"] = dataListXML.attributes["cppTemplateType"]
      end

      return(dInfo)
    end

    # Retrieve the standard version of this model's class
    def getStandardClassInfo(cls)
      cls.standard_class = cls.model.findClassSpecByPluginName("class_standard")

      if cls.standard_class.nil?
        Log.error("Unable to find standard class for :" + cls.model.name)
      end

      if cls.standard_class.namespace.hasItems?
        ns = cls.standard_class.namespace.get("::") + "::"
      else
        ns = ""
      end

      cls.standard_class_type = ns + Utils.instance.style_as_class(cls.get_u_name)

      if !cls.standard_class.nil? && cls.standard_class.plug_name != "enum"
        cls.addInclude(cls.standard_class.namespace.get("/"), style_as_class(cls.get_u_name))
      end

      return cls.standard_class
    end
  end
end
