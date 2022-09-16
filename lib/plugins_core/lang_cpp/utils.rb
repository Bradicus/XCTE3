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
        pDec << "const "
      end

      pDec << getTypeName(var)

      if var.passBy.upcase == "REFERENCE"
        pDec << "&"
      end
      if var.isPointer
        pDec << "*"
      end

      pDec << " " << getStyledVariableName(var)

      if var.arrayElemCount > 0
        pDec << "[]"
      end

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new
      typeName = String.new

      if var.isConst
        vDec << "const "
      end

      if var.isStatic
        vDec << "static "
      end

      vDec << getTypeName(var)

      if var.isPointer
        vDec << "*"
      end

      if var.passBy.upcase == "REFERENCE"
        vDec << "&"
      end

      vDec << " " << getStyledVariableName(var)

      if var.arrayElemCount.to_i > 0
        vDec << "[" + getSizeConst(var) << "]"
      end

      vDec << ";"

      if var.comment != nil
        vDec << "\t/** " << var.comment << " */"
      end

      return vDec
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
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

      if (var.listType != nil)
        typeName = getListTypeName(var.listType) + "<" + typeName + ">"
      end

      return typeName
    end

    def getSingleItemTypeName(var)
      typeName = ""
      baseTypeName = getBaseTypeName(var)

      if (var.isSharedPointer)
        typeName = "std::shared_ptr<" + baseTypeName + ">"
      end

      if (var.templateType != nil)
        typeName = var.templateType + "<" + baseTypeName + ">"
      end

      if (typeName.length == 0)
        typeName = baseTypeName
      end

      return typeName
    end

    # Return the language type based on the generic type
    def getBaseTypeName(var)
      nsPrefix = ""
      if var.namespace != nil
        nsPrefix = var.namespace.gsub(".", "::") + "::"
      end

      baseTypeName = ""
      if (var.vtype != nil)
        baseTypeName = @langProfile.getTypeName(var.vtype)
      else
        baseTypeName = CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end

      baseTypeName = nsPrefix + baseTypeName

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
      if cls.namespaceList.length > 0
        nsPrefix = cls.namespaceList.join("::") + "::"
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
      return "/* " << var.text << " */\n"
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

      if (cls.standardClass.namespaceList != nil)
        ns = cls.standardClass.namespaceList.join("::") + "::"
      else
        ns = ""
      end

      cls.standardClassType = ns + Utils.instance.getStyledClassName(cls.getUName())

      if (cls.standardClass != nil && cls.standardClass.ctype != "enum")
        cls.addInclude(cls.standardClass.namespaceList.join("/"), Utils.instance.getStyledClassName(cls.getUName()))
      end

      return cls.standardClass
    end
  end
end
