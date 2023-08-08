##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "code_elem_project.rb"
require "data_loading/attribute_util"
require "data_loading/namespace_util"
require "data_loading/variable_loader"
require "data_loading/class_loader"
require "data_loading/class_group_ref_loader"
require "code_elem_class_group_ref"
require "rexml/document"
require "class_groups"
require "utils_base"

module DataLoading
  class ModelLoader
    def self.loadModelFile(model, fName, pComponent)
      #BUtils = UtilsBase.new(nil)
      file = File.new(fName)
      model.xmlFileName = fName
      model.lastModified = file.mtime
      xmlString = file.read
      xmlDoc = REXML::Document.new xmlString
      depthStack = Array.new
      model.name = AttributeLoader.init(xmlDoc.root).names("name").get()
      model.featureGroup = AttributeLoader.init(xmlDoc.root).names("feature_group").get()
      model.xmlElement = xmlDoc.root

      xmlDoc.root.elements.each("derived") { |derived|
        model.derivedFrom = AttributeUtil.loadAttribute(derived, "from", pComponent)
        model.modelSet = AttributeUtil.loadAttribute(derived, "model_set", pComponent)
        if model.modelSet == nil
          Log.error("No model set for derived class in " + mdoel.name)
        end
      }

      xmlDoc.root.elements.each("description") { |desc|
        model.description = desc.text
      }
      xmlDoc.root.elements.each("var_group") { |vargXML|
        #puts "loading var group"
        newVGroup = CodeStructure::CodeElemVarGroup.new
        newVGroup.loadAttributes(vargXML)

        loadVarGroupNode(newVGroup, vargXML, pComponent)
        model.varGroup = newVGroup
      }

      xmlDoc.root.elements.each("paging") { |pXml|
        PagingLoader.loadPaging(model.paging, pXml)
      }

      xmlDoc.root.elements.each("gen_class") { |genCXML|
        cls = CodeStructure::CodeElemClassGen.new(model, model, pComponent, true)
        ClassLoader.loadClass(pComponent, cls, genCXML)
      }

      # Load class groups
      xmlDoc.root.elements.each("class_group_ref") { |nodeXml|
        cGroup = ClassGroups.get(nodeXml.attributes["name"])
        cgRef = CodeStructure::CodeElemClassGroupRef.new()
        ClassGroupRefLoader.loadClassGroupRef(cgRef, nodeXml)

        if cGroup != nil
          cGroup.xmlElement.elements.each("gen_class") { |genCXML|
            cls = CodeStructure::CodeElemClassGen.new(model, model, pComponent, true)
            cls.classGroupRef = cgRef
            ClassLoader.loadClass(pComponent, cls, genCXML)
          }
        end
      }
    end

    def self.loadClassGenNode(model, genCXML, pComponent, cgRefXml)
      cls = CodeStructure::CodeElemClassGen.new(model, model, pComponent, true)
      cgRef = CodeStructure::CodeElemClassGroupRef.new()
      ClassGroupRefLoader::loadClassGroupRef(cgRef, cgRefXml)

      ClassLoader.loadClass(pComponent, cls, genCXML)
      ClassModelManager.list << cls
      model.classes << cls

      if cls.interfaceNamespace.hasItems?()
        intf = processInterface(cls, model, pComponent)
        ClassModelManager.list << intf
        model.classes << intf
      end

      if cls.testNamespace.hasItems?()
        intf = ClassLoader.processTests(cls, model, pComponent)
        ClassModelManager.list << intf
        model.classes << cls
      end
    end

    # Loads a group node from an XML template vargroup node
    def self.loadVarGroupNode(vgNode, vgXML, pComponent)
      if (vgXML.attributes["name"] != nil)
        vgNode.name = vgXML.attributes["name"]
      end

      #puts "[ElemClass::loadVarGroupNode] loading var node "

      for varElem in vgXML.elements
        if (varElem.name.downcase == "variable" || varElem.name.downcase == "var")
          VariableLoader.loadVariableNode(varElem, vgNode, pComponent)
        elsif (varElem.name == "var_group")
          newVG = CodeStructure::CodeElemVarGroup.new
          newVG.loadAttributes(varElem)
          loadVarGroupNode(newVG, varElem, pComponent)
          vgNode.varGroups << newVG
        elsif (varElem.name == "comment")
          loadCommentNode(varElem, vgNode.vars)
        elsif (varElem.name == "br")
          #          loadBRNode(varElem, vgNode.vars)
        end
      end
    end
  end
end
