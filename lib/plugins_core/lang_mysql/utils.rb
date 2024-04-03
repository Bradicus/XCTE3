##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'

module XCTEMySql
  class Utils

    def initialize
      super('mysql')
    end

    # Returns variable declaration for the specified variable
    def self.get_var_dec(var)
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
    def self.get_type_name(gType)
      return @@langProfile.get_type_name(gType)
    end

    # Get the extension for a file type
    def self.get_extension(eType)
      return @@langProfile.get_extension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def self.get_comment(var)
      return '/* ' << var.text << " */\n"
    end

    def self.is_primitive(var)
      return @@langProfile.is_primitive(var)
    end
  end
end
