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
  
  # Return the language type based on the generic type
  def getTypeName(gType)
    return @langProfile.getTypeName(gType)
  end

  # Returns the version of this name styled for this language
  def getStyledVariableName(var, prefix = '')
    return CodeNameStyling.getStyled(var.name + prefix, @langProfile.variableNameStyle)
  end

  def getStyledFunctionName(funName)
    return CodeNameStyling.getStyled(funName, @langProfile.functionNameStyle)
  end

  # Returns the version of this class name styled for this language
  def getStyledClassName(className)
    return CodeNameStyling.getStyled(className, @langProfile.classNameStyle)
  end

  # Returns the version of this file name styled for this language
  def getStyledFileName(fileName)
    return CodeNameStyling.getStyled(fileName, @langProfile.fileNameStyle)
  end

end