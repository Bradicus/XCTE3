##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information specific to each programming language

require 'lang_profile_file_type.rb'
require 'lang_profile_type_map.rb'

class LangProfile
  attr_accessor :name, :fileTypes, :typeMaps, :variableNameStyle,
                :functionNameStyle, :classNameStyle, :fileNameStyle,
                :enumNameStyle

  def initialize
    @name       # Defined in the initialize method of child classes
    @fileTypes = Array.new  # Array of LangProfileFileType
    @typeMaps = Array.new   # Array of LangProfileTypeMap

    @variableNameStyle = nil
    @classNameStyle = nil
    @functionNameStyle = nil
    @fileNameStyle = nil
    @enumNameStyle = nil
  end
  
  def loadProfile
    begin
      codeRootDir = File.dirname(File.realpath(__FILE__))
      file = File.new(codeRootDir + "/../lang_profiles/" << name << ".xml")      
    rescue
      p 'error loading language profile ' << name << ".xml"
    end
    xmlDoc = REXML::Document.new file
    
    @fileTypes = Array.new
    
    xmlDoc.elements.each("LANGUAGE_DEFS/FILE_TYPES") { |fTypes|
      fTypes.elements.each("FILE_TYPE") { |fType|
        @fileTypes << LangProfileFileType.new( fType.attributes["type"], fType.attributes["extension"] )
      }
    }
    
    xmlDoc.elements.each("LANGUAGE_DEFS/TYPE_MAPS") { |typeMaps|
      typeMaps.elements.each("TYPE_MAP") { |typeMap|
        @typeMaps << LangProfileTypeMap.new(typeMap.attributes["genType"],
                                            typeMap.attributes["langType"],
                                            typeMap.attributes["autoIncludePath"],
                                            typeMap.attributes["autoIncludeName"],
                                            typeMap.attributes["autoIncludeType"])
      }
    }

    xmlDoc.elements.each("LANGUAGE_DEFS/STYLING") { |styling|
      @variableNameStyle = styling.attributes["variable"]
      @classNameStyle =  styling.attributes["class"]
      @functionNameStyle = styling.attributes["function"]
      @fileNameStyle = styling.attributes["file"]
      @enumNameStyle = styling.attributes["enum"]
    }

    if (@fileNameStyle == nil)
      @fileNameStyle = @classNameStyle
    end

    if (@variableNameStyle == nil)
      raise("Variable name style must be defined in type map for " + name)
    end
    if (@classNameStyle == nil)
      raise("Class name style must be defined in type map for " + name)
    end
    if (@functionNameStyle == nil)
      raise("Function name style must be defined in type map for " + name)
    end

  end
  
  def getExtension(extType)
    for fType in @fileTypes
      if (fType.fType == extType)
        return fType.fExtension
      end
    end

    return nil
  end
  
  def getTypeName(gType)
    for tMap in @typeMaps
      if tMap.genericType == gType
        return tMap.langType
      end
    end
    
    return gType  # If it can't find it just return the type
  end

  def getType(genericType)
    for tMap in @typeMaps
      if tMap.genericType == genericType
        if tMap.autoInclude != nil && tMap.autoInclude.name != nil
          return tMap
        end
      end
    end

    return nil
  end

  def isPrimitive(var)
    for tMap in @typeMaps
      if tMap.genericType == var.vtype
        return true
      end
    end    
    
    return false
  end
  
end
