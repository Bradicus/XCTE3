##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information specific to each programming language

require "lang_profile_file_type"
require "lang_profile_type_map"

class LangProfile
  attr_accessor :name, :fileTypes, :typeMaps, :variableNameStyle,
                :functionNameStyle, :classNameStyle, :fileNameStyle,
                :enumNameStyle, :constNameStyle, :directoryNameStyle, :namespaceStyle

  def initialize(name) # Defined in the initialize method of child classes
    @name = name

    @fileTypes = []  # Array of LangProfileFileType
    @typeMaps = []   # Array of LangProfileTypeMap

    @variableNameStyle = nil
    @classNameStyle = nil
    @functionNameStyle = nil
    @fileNameStyle = nil
    @directoryNameStyle = nil
    @enumNameStyle = nil
    @constNameStyle = nil
    @namespaceStyle = nil
  end

  def load(xmlDoc)
    @fileTypes = []

    xmlDoc.elements.each("LANGUAGE_DEFS/FILE_TYPES") do |fTypes|
      fTypes.elements.each("FILE_TYPE") do |fType|
        @fileTypes << LangProfileFileType.new(fType.attributes["type"], fType.attributes["extension"])
      end
    end

    xmlDoc.elements.each("LANGUAGE_DEFS/TYPE_MAPS") do |typeMaps|
      typeMaps.elements.each("TYPE_MAP") do |typeMap|
        @typeMaps << LangProfileTypeMap.new(typeMap.attributes["genType"],
                                            typeMap.attributes["langType"],
                                            typeMap.attributes["tplType"],
                                            typeMap.attributes["autoIncludePath"],
                                            typeMap.attributes["autoIncludeName"],
                                            typeMap.attributes["autoIncludeType"])
      end
    end

    xmlDoc.elements.each("LANGUAGE_DEFS/STYLING") do |styling|
      @variableNameStyle = styling.attributes["variable"]
      @classNameStyle = styling.attributes["class"]
      @functionNameStyle = styling.attributes["function"]
      @fileNameStyle = styling.attributes["file"]
      @directoryNameStyle = styling.attributes["directory"]
      @enumNameStyle = styling.attributes["enum"]
      @constNameStyle = styling.attributes["const"]
      @namespaceStyle = styling.attributes["namespace"]
    end

    if @fileNameStyle.nil?
      @fileNameStyle = @classNameStyle
    end

    if @variableNameStyle.nil?
      raise("Variable name style must be defined in type map for " + name)
    end
    if @classNameStyle.nil?
      raise("Class name style must be defined in type map for " + name)
    end
    return unless @functionNameStyle.nil?

    raise("Function name style must be defined in type map for " + name)
  end

  def get_extension(extType)
    for fType in @fileTypes
      if fType.fType == extType
        return fType.fExtension
      end
    end

    return nil
  end

  def get_type_name(gType)
    for tMap in @typeMaps
      if tMap.genericType == gType
        return tMap.langType

        # return tMap.langType + '#' + tMap.tplType

      end
    end

    return gType # If it can't find it just return the type
  end

  def get_type(genericType)
    for tMap in @typeMaps
      if tMap.genericType == genericType && (!tMap.autoInclude.nil? && !tMap.autoInclude.name.nil?)
        return tMap
      end
    end

    return nil
  end

  def is_primitive(var)
    for tMap in @typeMaps
      if tMap.genericType.downcase == var.getUType().downcase
        return true
      end
    end

    return false
  end
end
