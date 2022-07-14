##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile.rb"
require "utils_base"

module XCTETypescript
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("typescript")
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << getTypeName(var.vtype)

      pDec << " " << var.name

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

      vDec << getStyledVariableName(var)
      vDec << ": " + getTypeName(var)

      if var.arrayElemCount.to_i > 0 && var.vtype != "String"
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

    # Get a type name for a variable
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

      baseTypeName = ""
      if (var.vtype != nil)
        baseTypeName = @langProfile.getTypeName(var.vtype)
      else
        baseTypeName = CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end

      baseTypeName = nsPrefix + baseTypeName

      return baseTypeName
    end

    def getListTypeName(listTypeName)
      return @langProfile.getTypeName(listTypeName)
    end

    # Get the extension for a file type
    def getExtension(eType)
      return @langProfile.getExtension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return "/* " << var.text << " */\n"
    end

    def isPrimitive(var)
      return @langProfile.isPrimitive(var)
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
  end
end
