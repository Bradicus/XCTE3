##

#
# Copyright XCTE Contributors
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

      vDec << "@" << getStyledVariableName(var)

      if var.arrayElemCount.to_i > 0
        vDec << " = Array.new(" << getSizeConst(var) << ")"
      end

      if (var.defaultValue != nil)
        vDec << " = "
        if var.vtype == "String"
          vDec << "\"" << var.defaultValue << "\";"
        else
          vDec << var.defaultValue << ";"
        end
      end

      if var.comment != nil
        vDec << "\t# " << var.comment
      end

      return vDec
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
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

    # Get type for a class
    def getClassTypeName(cls)
      nsPrefix = ""
      if cls.namespace.hasItems?()
        nsPrefix = cls.namespace.get("::") + "::"
      end

      baseTypeName = CodeNameStyling.getStyled(cls.name, @langProfile.classNameStyle)
      baseTypeName = nsPrefix + baseTypeName

      return baseTypeName
    end

    def render_block_comment(str, bld)
      firstLine = true

      if str != nil && str.strip().length > 0
        bld.add "##"
        str.each_line do |line|
          if (!firstLine || line.strip().length > 0)
            bld.add("# " + line.delete("\n"))
            firstLine = false
          end
        end
      end
    end
  end
end
