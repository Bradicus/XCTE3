##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information specific to each programming language

require 'lang_profile_file_type.rb'
require 'lang_profile_type_map.rb'

class LangProfile
  attr_accessor :name, :fileTypes, :typeMaps
  
  def initialize
    @name       # Defined in the initialize method of child classes
    @fileTypes = Array.new  # Array of LangProfileFileType
    @typeMaps = Array.new   # Array of LangProfileTypeMap
    @defaultFormatting
  end
  
  def loadProfile
    begin
      file = File.new("../lang_profiles/" << name << ".xml")      
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
        @typeMaps << LangProfileTypeMap.new(typeMap.attributes["genType"], typeMap.attributes["langType"])
      }
    }   
  end
  
  def getExtension(extType)
    for fType in @fileTypes
      if (fType.fType == extType)
        return fType.fExtension
      end
    end
  end
  
  def getTypeName(gType)
    for tMap in @typeMaps
      if tMap.genericType == gType
        return tMap.langType
      end
    end
    
    return gType  # If it can't find it just return the type
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
