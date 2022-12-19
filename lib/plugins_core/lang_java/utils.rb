##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile.rb"
require "utils_base"

module XCTEJava
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("java")
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << self.getTypeName(var)

      pDec << " " << self.getStyledVariableName(var)

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new

      vDec << var.visibility << " "

      if var.isConst
        vDec << "const "
      end

      if var.isStatic
        vDec << "static "
      end

      if var.isVirtual
        vDec << "virtual "
      end

      if (var.templateType != nil)
        vDec << var.templateType << "<" << self.getTypeName(var) << ">"
      elsif (var.listType != nil)
        vDec << var.listType << "<" << self.getTypeName(var) << ">"
      else
        vDec << self.getTypeName(var)
      end

      vDec << " "

      if var.nullable
        vDec << "?"
      end

      vDec << self.getStyledVariableName(var)
      vDec << ";"

      if var.comment != nil
        vDec << "\t/** " << var.comment << " */"
      end

      return vDec
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "MAX_LEN_" << var.name.upcase
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

    def getStyledUrlName(name)
      return CodeNameStyling.getStyled(name, "DASH_LOWER")
    end

    def addClassInclude(cls, ctype)
      cls.addUse(cls.model.findClassByType(ctype).namespace.get("."))
    end
  end
end
