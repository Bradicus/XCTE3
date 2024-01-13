##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'
require 'utils_base'

module XCTESql
  class Utils < UtilsBase
    include Singleton
    @@langProfile = LangProfile.new

    def initialize
      super('sql')
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new

      vDec << '`' << var.name << '` '
      if var.arrayElemCount.to_i > 0 # All arrays will be csv strings
        vDec << 'TEXT'
      else
        tName = get_type_name(var.vtype)

        if tName != var.vtype
          vDec << tName
        else
          vDec << 'TEXT'
        end
      end

      return vDec
    end

    # Get a parameter declaration for a method parameter
    def get_type_name(gType)
      return @@langProfile.get_type_name(gType)
    end

    # Get the extension for a file type
    def get_extension(eType)
      return @@langProfile.get_extension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return '/* ' << var.text << " */\n"
    end

    def is_primitive(var)
      return @@langProfile.is_primitive(var)
    end

    def getStyledTableName(name)
      return CodeNameStyling.getStyled(name, @langProfile.classNameStyle)
    end
  end
end
