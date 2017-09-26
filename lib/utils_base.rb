#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions useful for all languages.

require 'lang_profile.rb'

class UtilsBase

  def initialize(langName)
    @langProfile = LangProfile.new
    @langProfile.name = langName
    @langProfile.loadProfile
  end
  
  # Returns true if this is a primitive data type
  def isPrimitive(var)
    return @langProfile.isPrimitive(var)
  end
  
  # Return the language type based on the generic type
  def getTypeName(var)
    if (var.vtype != nil)
      return @langProfile.getTypeName(var.vtype)
    else
      return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
    end
  end
  
  # Return the language type based on the generic type
  def getType(gType)
    return @langProfile.getType(gType)
  end

  # Returns the version of this name styled for this language
  def getStyledVariableName(var, prefix = '', postfix = '')
    return CodeNameStyling.getStyled(prefix + var.name + postfix, @langProfile.variableNameStyle)
  end

  def getStyledFunctionName(funName)
    return CodeNameStyling.getStyled(funName, @langProfile.functionNameStyle)
  end

  # Returns the version of this class name styled for this language
  def getStyledClassName(className)
    return CodeNameStyling.getStyled(className, @langProfile.classNameStyle)
  end

  def getStyledEnumName(enumName)
    return CodeNameStyling.getStyled(enumName, @langProfile.enumNameStyle)
  end

  # Returns the version of this file name styled for this language
  def getStyledFileName(fileName)
    return CodeNameStyling.getStyled(fileName, @langProfile.fileNameStyle)
  end
  
  # Get the extension for a file type
  def getExtension(eType)
    return @langProfile.getExtension(eType)
  end

end