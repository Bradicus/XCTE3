##

#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'
require 'utils_base'
require 'singleton'

module XCTERazor
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('csharp')
    end

    # Returns variable declaration for the specified variable
    def get_var_dec(var, var_prefix = '')
      vDec = String.new

      vDec << '[' + CodeNameStyling.getStyled(var_prefix + var.name, @langProfile.variableNameStyle) + ']'

      tName = get_type_name(var)

      if tName != var.vtype
        vDec << ' ' + tName
        if var.identity
          vDec << ' IDENTITY' << var.identity
        end
      else
        vDec << 'TEXT'
      end

      return vDec
    end

    # Get a parameter declaration for a method parameter
    def get_type_name(var)
      if var.vtype == 'String'
        return('TEXT') if var.arrayElemCount > 9999

        return('VARCHAR(' + var.arrayElemCount.to_s + ')')

      elsif var.vtype == 'StringUNC16'
        return('NTEXT') if var.arrayElemCount > 9999

        return('NVARCHAR(' + var.arrayElemCount + ')')

      end

      return @langProfile.get_type_name(var.vtype)
    end

    # Get the extension for a file type
    def get_extension(eType)
      return @langProfile.get_extension(eType)
    end

    # Returns the version of this name styled for this language
    def get_styled_variable_name(var, var_prefix = '')
      return CodeNameStyling.getStyled(var, @langProfile.variableNameStyle) unless var.is_a?(CodeElemVariable)
      if var.genGet || var.genSet
        return CodeNameStyling.getStyled(var_prefix + var.name, @langProfile.functionNameStyle)
      end

      return CodeNameStyling.getStyled(var_prefix + var.name, @langProfile.variableNameStyle)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def get_comment(var)
      return '@* ' << var.text << " *@\n"
    end
  end
end
