##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "code_elem_project.rb"
require "data_processing/attribute_util"
require "data_processing/namespace_util"
require "data_processing/variable_loader"
require "data_processing/class_loader"
require "rexml/document"

module DataProcessing
  class ModelLoader
    def self.loadModelFile(model, fName, pComponent)
      file = File.new(fName)
      model.xmlFileName = fName
      model.lastModified = file.mtime
      xmlString = file.read
      xmlDoc = REXML::Document.new xmlString
      depthStack = Array.new
      model.name = xmlDoc.root.attributes["name"]
      model.xmlElement = xmlDoc.root

      xmlDoc.root.elements.each("derived") { |derived|
        model.derivedFrom = AttributeUtil.loadAttribute(derived, "from", pComponent)
        model.derivedFor = AttributeUtil.loadAttribute(derived, "for", pComponent)
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
      xmlDoc.root.elements.each("gen_class") { |genCXML|
        cls = CodeStructure::CodeElemClassGen.new(model, model, true)
        ClassLoader.loadClass(pComponent, cls, genCXML)
        cls.model = model
        cls.xmlElement = genCXML
        Classes.list << cls
        model.classes << cls

        if cls.interfaceNamespace.hasItems?()
          intf = CodeStructure::CodeElemClassGen.new(cls, model, true)
          intf.namespace = CodeStructure::CodeElemNamespace.new(cls.interfaceNamespace.get("."))
          intf.path = cls.interfacePath
          intf.functions = cls.functions
          intf.language = cls.language
          intf.ctype = "interface"
          intf.parentElem = cls
          intf.model = model
          Classes.list << intf
          model.classes << intf
        end

        if cls.testNamespace.hasItems?()
          intf = CodeStructure::CodeElemClassGen.new(cls, model, true)
          intf.namespace = CodeStructure::CodeElemNamespace.new(cls.testNamespace.get("."))
          intf.path = cls.testPath
          intf.language = cls.language
          intf.ctype = "test_engine"
          intf.parentElem = cls
          intf.model = model
          Classes.list << intf
          model.classes << cls
        end
      }
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
