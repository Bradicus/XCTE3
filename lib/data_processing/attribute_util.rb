##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "rexml/document"

module DataProcessing
  class AttributeUtil
    def self.hasAttribute(xmlNode, attName)
      return xmlNode.attributes.get_attribute(attName) != nil
    end

    # Load an attribute
    def self.loadAttribute(xml, atrNames, language, default = nil)
      if !atrNames.kind_of?(Array)
        atrNames = Array[atrNames]
      end

      for atrName in atrNames
        atr = xml.attributes[atrName + "-" + language]
        if atr != nil
          return atr
        end
        atr = xml.attributes[atrName]
        if atr != nil
          return atr
        end
      end

      return default
    end

    # Load an attribute
    def self.loadInheritableAttribute(xml, atrNames, language, default = nil)
      if !atrNames.kind_of?(Array)
        atrNames = Array[atrNames]
      end

      for atrName in atrNames
        atr = xml.attributes[atrName + "-" + language]
        if atr != nil
          return atr
        end
        atr = xml.attributes[atrName]
        if atr != nil
          return atr
        end
      end

      # Parent if we didn't find it
      if (xml.parent != nil && xml.parent.name == "var_group")
        pLoad = loadInheritableAttribute(xml.parent, atrNames, language, nil)
        if (pLoad != nil)
          return pLoad
        end
      end

      return default
    end

    def self.loadAttributeArray(xml, atrNames, language, separator)
      atr = loadAttribute(xml, atrNames, language)
      if atr != nil
        return atr.split(separator)
      end

      return Array.new
    end

    def self.loadTemplateAttribute(var, varXml, attribName, language)
      tpls = loadAttribute(varXml, attribName, language)

      tplItems = tpls.split(",")
      for tplItem in tplItems
        tplC = CodeStructure::CodeElemTemplate.new(tplItem.strip())
        var.templates.push(tplC)
      end
    end
  end
end
