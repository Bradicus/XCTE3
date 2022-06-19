##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "plugins_core/lang_ruby/x_c_t_e_ruby.rb"
require "lang_profile.rb"
require "utils_base"

module XCTERuby
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("ruby")
    end

    def getClassName(var)
      if (var.vtype != nil)
        return @langProfile.getTypeName(var.vtype)
      else
        return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << getTypeName(var.vtype)

      pDec << " " << var.name

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new

      if var.isStatic
        vDec << "@"
      end

      vDec << "@" << var.name

      if var.arrayElemCount.to_i > 0
        vDec << " = Array.new(" << getSizeConst(var) << ")"
      end

      if var.comment != nil
        vDec << "\t# " << var.comment
      end

      vDec << "\n"

      return vDec
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
    end

    # Get a parameter declaration for a method parameter
    def getTypeName(gType)
      return @langProfile.getTypeName(gType)
    end

    # Get the extension for a file type
    def getExtension(eType)
      return @langProfile.getExtension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return "# " << var.text << " \n"
    end

    def isPrimitive(var)
      return @langProfile.isPrimitive(var)
    end
  end
end
