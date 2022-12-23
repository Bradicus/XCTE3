##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile.rb"

module XCTESql
  class Utils
    @@langProfile = LangProfile.new

    def self.init
      @@langProfile.name = "sql"
      @@langProfile.loadProfile
    end

    # Returns variable declaration for the specified variable
    def self.getVarDec(var)
      vDec = String.new

      vDec << "`" << var.name << "` "
      if (var.arrayElemCount.to_i > 0) # All arrays will be csv strings
        vDec << "TEXT"
      else
        tName = self.getTypeName(var.vtype)

        if tName != var.vtype
          vDec << tName
        else
          vDec << "TEXT"
        end
      end

      return vDec
    end

    # Get a parameter declaration for a method parameter
    def self.getTypeName(gType)
      return @@langProfile.getTypeName(gType)
    end

    # Get the extension for a file type
    def self.getExtension(eType)
      return @@langProfile.getExtension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def self.getComment(var)
      return "/* " << var.text << " */\n"
    end

    def self.isPrimitive(var)
      return @@langProfile.isPrimitive(var)
    end

    def getStyledTableName(name)
      return CodeNameStyling.getStyled(fileName, @langProfile.tableNameStyle)
    end
  end
end
