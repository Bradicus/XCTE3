##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads attribute information form an XML node

require "rexml/document"
require "params/build_var_params"
require "active_component"

module DataLoading
  class AttributeLoader
    attr_accessor :value, :model, :clsGen

    @names = Array.new
    @model = nil
    @clsGen = nil
    @xml = nil
    @default = nil
    @inheritable = false
    @arrayDelim = nil
    @isTemplateAttrib = false

    def self.init()
      return AttributeLoader.new
    end

    def xml(xml)
      @xml = xml
      return self
    end

    def names(names)
      if !names.kind_of?(Array)
        names = Array[names]
      end
      @names = names

      return self
    end

    def doInherit()
      @inheritable = true
      return self
    end

    def arrayDelim(arrayDelim)
      @arrayDelim = arrayDelim
      return self
    end

    def isTplAttrib()
      @isTemplateAttrib = true
      return self
    end

    def model(model)
      @model = model
      return self
    end

    def cls(clsGen)
      @clsGen = clsGen
      return self
    end

    def var(var)
      @var = var
      return self
    end

    def default(default)
      @default = default
      return self
    end

    def get(var = nil)
      loadAttrib(@xml, var)
    end

    def loadAttrib(xml, var = nil)
      for atrName in @names
        # Check for language specific version of attrib
        atr = xml.attributes[atrName + "-" + ActiveComponent.get().language]
        if (atr == nil)
          # Check for regular version of attrib
          atr = xml.attributes[atrName]
        end
        if atr != nil
          value = processBuildVars(atr)
          if @arrayDelim != nil
            value = value.split(@arrayDelim)
          end

          if (@isTemplateAttrib)
            tplItems = value.split(",")
            for tplItem in tplItems
              tplC = CodeStructure::CodeElemTemplate.new(tplItem.strip())
              var.templates.push(tplC)
            end
          end

          return value
        end
      end

      if (@inheritable)
        # Cheeck parent if we didn't find it
        if (xml.parent != nil && xml.parent.name == "var_group")
          pLoad = loadAttrib(xml.parent, var)
          if (pLoad != nil)
            return pLoad
          end
        end
      end

      if @arrayDelim != nil
        return Array.new
      else
        return @default
      end
    end

    def processBuildVars(value)
      newVal = value

      for bv in ActiveComponent.get().buildVars
        newVal = newVal.gsub("$" + bv.name, bv.value)
        newVal = newVal.gsub("{" + bv.name + "}", bv.value)
      end

      if @model != nil
        newVal = newVal.gsub("{ModelName}", @model.name)
      end

      if @clsGen != nil && @clsGen.featureGroup != nil
        newVal = newVal.gsub("{FeatureGroup}", @clsGen.featureGroup)
      end

      return newVal
    end
  end
end
