##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "rexml/document"

module DataLoading
  class AttributeUtil
    def self.hasAttribute(xmlNode, attName)
      return xmlNode.attributes.get_attribute(attName) != nil
    end

    def self.loadAttrib()
      return AttributeUtil.new()
    end

    def wXml(xml)
      @xml = xml

      return self
    end

    def wModel(model)
      @model = model
      return self
    end

    def wCls(cls)
      @clsGen = cls

      return self
    end

    def wVar(var)
      @var = var
      return self
    end

    def wComp(pComp)
      @pComp = pComp
      return self
    end

    def wValue(value)
      @value = value
      return self
    end

    # Load an attribute
    def self.loadAttribute(xml, atrNames, pComponent, default = nil, model = nil)
      if !atrNames.kind_of?(Array)
        atrNames = Array[atrNames]
      end

      for atrName in atrNames
        atr = xml.attributes[atrName + "-" + pComponent.language]
        if atr != nil
          return processBuildVars(BuildVarParams.new().wValue(atr).wComp(pComponent).wModel(model))
        end
        atr = xml.attributes[atrName]
        if atr != nil
          return processBuildVars(BuildVarParams.new().wValue(atr).wComp(pComponent).wModel(model))
        end
      end

      return default
    end

    # Load an attribute
    def self.loadInheritableAttribute(xml, atrNames, pComponent, default = nil)
      if !atrNames.kind_of?(Array)
        atrNames = Array[atrNames]
      end

      for atrName in atrNames
        atr = xml.attributes[atrName + "-" + pComponent.language]
        if atr != nil
          return processBuildVars(BuildVarParams.new().wValue(atr).wComp(pComponent))
        end
        atr = xml.attributes[atrName]
        if atr != nil
          return processBuildVars(BuildVarParams.new().wValue(atr).wComp(pComponent))
        end
      end

      # Parent if we didn't find it
      if (xml.parent != nil && xml.parent.name == "var_group")
        pLoad = loadInheritableAttribute(xml.parent, atrNames, pComponent, nil)
        if (pLoad != nil)
          return pLoad
        end
      end

      return default
    end

    def self.loadAttributeArray(xml, atrNames, pComponent, separator)
      atr = loadAttribute(xml, atrNames, pComponent)
      if atr != nil
        return atr.split(separator)
      end

      return Array.new
    end

    def self.loadTemplateAttribute(var, varXml, attribName, pComponent)
      tpls = loadAttribute(varXml, attribName, pComponent)

      tplItems = tpls.split(",")
      for tplItem in tplItems
        tplC = CodeStructure::CodeElemTemplate.new(tplItem.strip())
        var.templates.push(tplC)
      end
    end

    def self.processBuildVars(buildVarParams)
      newVal = buildVarParams.value

      for bv in buildVarParams.pComp.buildVars
        newVal.gsub!("$" + bv.name, bv.value)
        newVal.gsub!("{" + bv.name + "}", bv.value)
      end

      if buildVarParams.model != nil
        newVal.gsub!("{ModelName}", buildVarParams.model.name)
      end

      # if buildVarParams.featureGroup != nil
      #   newVal.gsub!("{FeatureGroup}", buildVarParams.featureGroup)
      # end

      return newVal
    end
  end
end
