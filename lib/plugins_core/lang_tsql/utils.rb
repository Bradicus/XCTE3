##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class contains utility functions for a language
 
require 'lang_profile.rb'

module XCTETSql
  class Utils
    @@langProfile = LangProfile.new
    
    def self.init
      @@langProfile.name = "tsql"   
      @@langProfile.loadProfile
    end
    
    # Returns variable declaration for the specified variable
    def self.getVarDec(var)
      vDec = String.new
      
      vDec << "[" << var.name << "] "

      tName = self.getTypeName(var)

      if tName != var.vtype
        vDec << tName
      else
        vDec << "TEXT"
      end

      return vDec
    end
        
    # Get a parameter declaration for a method parameter
    def self.getTypeName(var)
      if (var.vtype == "String")
        if (var.arrayElemCount > 9999)
          return("TEXT")
        else
          return("VARCHAR(" + var.arrayElemCount.to_s + ")")
        end
      else
        if (var.vtype == "StringUNC16")
          if (var.arrayElemCount > 9999)
            return("NTEXT")
          else
            return("NVARCHAR(" + var.arrayElemCount + ")")
          end
        end
      end

      return @@langProfile.getTypeName(var.vtype)
    end
    
    # Get the extension for a file type
    def self.getExtension(eType)
      return @@langProfile.getExtension(eType)
    end

    def getStandardAutoIncludes()

    end
    
    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def self.getComment(var)
      return "/* " << var.text << " */\n"
    end
    
    def self.isPrimitive(var)
      return @@langProfile.isPrimitive(var)
    end
  end
end

