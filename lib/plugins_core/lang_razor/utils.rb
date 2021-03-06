##

# 
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class contains utility functions for a language
 
require 'lang_profile.rb'
require 'utils_base.rb'
require 'singleton'

module XCTERazor
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('csharp')
    end
    
    # Returns variable declaration for the specified variable
    def getVarDec(var, varPrefix = '')
      vDec = String.new
      
      vDec << '[' + CodeNameStyling.getStyled(varPrefix + var.name, @langProfile.variableNameStyle) + ']'

      tName = getTypeName(var)

      if tName != var.vtype
        vDec << ' ' + tName
        if (var.identity)
          vDec << ' IDENTITY' << var.identity
        end
      else
        vDec << "TEXT"
      end

      return vDec
    end
        
    # Get a parameter declaration for a method parameter
    def getTypeName(var)
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

      return @langProfile.getTypeName(var.vtype)
    end
    
    # Get the extension for a file type
    def getExtension(eType)
      return @langProfile.getExtension(eType)
    end

    # Returns the version of this name styled for this language
    def getStyledVariableName(var, varPrefix = '')
      if var.is_a?(CodeElemVariable)
        if (var.genGet || var.genSet)
          return CodeNameStyling.getStyled(varPrefix + var.name, @langProfile.functionNameStyle)
        else
          return CodeNameStyling.getStyled(varPrefix + var.name, @langProfile.variableNameStyle)
        end
      else
        return CodeNameStyling.getStyled(var, @langProfile.variableNameStyle)
      end
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return "@* " << var.text << " *@\n"
    end
    
    def isPrimitive(var)
      return @langProfile.isPrimitive(var)
    end

  end
end
