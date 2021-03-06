##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class contains utility functions for a language
 
require 'lang_profile.rb'
require 'utils_base'

module XCTETypescript
  class Utils < UtilsBase
    
    # Get a parameter declaration for a method parameter
    def self.getParamDec(var)
      pDec = String.new
                
      pDec << getTypeName(var.vtype);
        
      pDec << " " << var.name;
      
      if var.arrayElemCount > 0
        pDec << "[]"
      end
      
      return pDec
    end
    
    # Returns variable declaration for the specified variable
    def self.getVarDec(var)
      vDec = String.new
                
      vDec << "{ name: '" << var.name << "'";
      
      if (var.vtype != nil)
      vDec << ", type: '" << getTypeName(var.vtype) << "'"
      end
      vDec << " }";
      
      if var.comment != nil
        vDec << "\t/** " << var.comment << " */";
      end
        
     # vDec << "\n";
      
      return vDec
    end
  
    # Returns a size constant for the specified variable
    def self.getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
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

    # Capitalizes the first letter of a string
    def self.getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0,1].capitalize

      if (str.length > 1)
        newStr += str[1..str.length - 1]
      end

      return(newStr)
    end
  end
end
