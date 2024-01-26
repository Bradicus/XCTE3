##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads attribute information form an XML node

require "rexml/document"
require "params/build_var_params"
require "active_component"
require "log"

module DataLoading
  class AttributeLoader

    @names = Array.new
    @dmodel = nil
    @cls_gen = nil
    @xml = nil
    @default = nil
    @inheritable = false
    @arrayDelim = nil
    @isTemplateAttrib = false
    @required = false

    def self.init(xmlNode = nil)
      al = AttributeLoader.new
      if xmlNode != nil
        al.xml(xmlNode)
      end

      return al
    end

    def xml(xmlNode)
      if xmlNode.is_a?(REXML::Element)
        @xml = xmlNode
      else
        throw "INVALID xml element"
      end
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

    def required()
      @required = true
      return self
    end

    def model(dmodel)
      @dmodel = dmodel
      return self
    end

    def cls(cls_gen)
      @cls_gen = cls_gen
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
        atr = get_attribute(xml, atrName)

        if atr != nil
          if ActiveComponent.get() != nil
            value = process_build_vars(atr)
            if @arrayDelim != nil
              value = value.split(@arrayDelim)

              for val in value
                val.strip!()
              end
            end
          end

          if (@isTemplateAttrib && value != nil)
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
        if @required
          Log.error("Failed to load required attribute: " + @names.join(","))
        end

        return @default
      end
    end

    def get_attribute(aXml, name)
      atr = nil
      if ActiveComponent.get() != nil
        atr = aXml.attributes[name + "-" + ActiveComponent.get().language]
      end

      if (atr == nil)
        # Check for regular version of attrib
        atr = aXml.attributes[name]
      end

      return atr
    end

    def process_build_vars(value)
      newVal = value

      for bv in ActiveComponent.get().buildVars
        newVal = newVal.gsub("$" + bv.name, bv.value)
        newVal = newVal.gsub("{" + bv.name + "}", bv.value)
      end

      if @dmodel != nil
        newVal = newVal.gsub("!{ModelName}", @dmodel.name)
      end

      if @cls_gen != nil && @cls_gen.featureGroup != nil
        newVal = newVal.gsub("!{FeatureGroup}", @cls_gen.featureGroup)
      else
        newVal = newVal.gsub("!{FeatureGroup}", "")
      end

      if @cls_gen != nil && @cls_gen.variant != nil
        newVal = newVal.gsub("!{ClassGroupVariant}", @cls_gen.variant)
      else
        newVal = newVal.gsub("!{ClassGroupVariant}", "")
      end

      if @cls_gen != nil && @cls_gen.class_group_ref != nil && @cls_gen.class_group_ref.name != nil
        newVal = newVal.gsub("!{ClassGroupName}", @cls_gen.class_group_ref.name)
      else
        newVal = newVal.gsub("!{ClassGroupName}", "")
      end

      return newVal.strip
    end
  end
end
