##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains the language profile for C++ and utility fuctions
# used by various plugins

require "code_name_styling.rb"
require "utils_base.rb"
require "singleton"

module XCTECpp
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("cpp")
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      if var.isConst
        pDec += "const "
      end

      pDec += getTypeName(var)

      if var.passBy.upcase == "REFERENCE"
        pDec += "&"
      end
      if var.isPointer
        pDec += "*"
      end

      pDec += " " + getStyledVariableName(var)

      if var.arrayElemCount > 0
        pDec += "[]"
      end

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new
      typeName = String.new

      if var.isConst
        vDec += "const "
      end

      if var.isStatic
        vDec += "static "
      end

      vDec += getTypeName(var)

      if var.isPointer
        vDec += "*"
      end

      if var.passBy.upcase == "REFERENCE"
        vDec += "&"
      end

      vDec += " " + getStyledVariableName(var)

      if var.arrayElemCount.to_i > 0
        vDec += "[" + getSizeConst(var) + "]"
      end

      vDec += ";"

      if var.comment != nil
        vDec += "\t/** " + var.comment + " */"
      end

      return vDec
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "ARRAYSZ_" + var.name.upcase
    end

    # Capitalizes the first letter of a string
    def getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      if (str.length > 1)
        newStr += str[1..str.length - 1]
      end

      return(newStr)
    end

    # Return the language type based on the generic type
    def getTypeName(var)
      typeName = getSingleItemTypeName(var)

      if var.templates.length > 0 && var.templates[0].isCollection
        tplType = @langProfile.getTypeName(var.templates[0].name)
        typeName = tplType + "<" + typeName + ">"
      end

      return typeName
    end

    def getSingleItemTypeName(var)
      typeName = getBaseTypeName(var)

      singleTpls = var.templates
      if singleTpls.length > 0 && singleTpls[0].isCollection
        singleTpls = singleTpls.drop(1)
      end

      for tpl in singleTpls.reverse()
        typeName = tpl.name + "<" + typeName + ">"
      end

      return typeName.strip
    end

    # Return the language type based on the generic type
    def getBaseTypeName(var)
      nsPrefix = ""
      langType = @langProfile.getTypeName(var.getUType())

      if (var.utype != nil) # Only unformatted name needs styling
        baseTypeName = CodeNameStyling.getStyled(langType, @langProfile.classNameStyle)
      else
        baseTypeName = langType
      end

      if var.namespace.hasItems?()
        nsPrefix = var.namespace.get("::") + "::"
        baseTypeName = nsPrefix + baseTypeName
      end

      return baseTypeName
    end

    def getClassName(var)
      if (var.vtype != nil)
        return @langProfile.getTypeName(var.vtype)
      else
        return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end
    end

    def getClassTypeName(cls)
      nsPrefix = ""
      if cls.namespace.hasItems?()
        nsPrefix = cls.namespace.get("::") + "::"
      end

      baseTypeName = CodeNameStyling.getStyled(cls.name, @langProfile.classNameStyle)
      baseTypeName = nsPrefix + baseTypeName

      if (cls.templateParams.length > 0)
        allParams = Array.new

        for param in cls.templateParams
          allParams.push(CodeNameStyling.getStyled(param.name, @langProfile.classNameStyle))
        end

        baseTypeName += "<" + allParams.join(", ") + ">"
      end

      return baseTypeName
    end

    def getDerivedClassPrefix(cls)
      tplNames = Array.new
      for tplParam in cls.templateParams
        tplNames.push(tplParam.name)
      end

      if tplNames.length > 0
        return CodeNameStyling.getStyled(cls.name, @langProfile.classNameStyle) + tplNames.join("")
      end

      return CodeNameStyling.getStyled(cls.name, @langProfile.classNameStyle)
    end

    def getListTypeName(listTypeName)
      return @langProfile.getTypeName(listTypeName)
    end

    def getComment(var)
      return "/* " + var.text + " */\n"
    end

    def getZero(var)
      if var.vtype == "Float32"
        return "0.0f"
      end
      if var.vtype == "Float64"
        return "0.0"
      end

      return "0"
    end

    def getDataListInfo(classXML)
      dInfo = Hash.new

      classXML.elements.each("DATA_LIST_TYPE") { |dataListXML|
        dInfo["cppTemplateType"] = dataListXML.attributes["cppTemplateType"]
      }

      return(dInfo)
    end

    # Retrieve the standard version of this model's class
    def getStandardClassInfo(cls)
      cls.standardClass = cls.model.findClassByType("standard")

      if (cls.standardClass.namespace.hasItems?)
        ns = cls.standardClass.namespace.get("::") + "::"
      else
        ns = ""
      end

      cls.standardClassType = ns + Utils.instance.getStyledClassName(cls.getUName())

      if (cls.standardClass != nil && cls.standardClass.plugName != "enum")
        cls.addInclude(cls.standardClass.namespace.get("/"), Utils.instance.getStyledClassName(cls.getUName()))
      end

      return cls.standardClass
    end
  end
end
