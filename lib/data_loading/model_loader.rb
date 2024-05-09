##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "code_structure/code_elem_project"
require "data_loading/attribute_loader"
require "data_loading/namespace_util"
require "data_loading/variable_loader"
require "data_loading/class_loader"
require "data_loading/code_elem_loader"
require "data_loading/class_group_ref_loader"
require "code_structure/code_elem_class_group_ref"
require "rexml/document"
require "class_groups"
require "utils_base"

module DataLoading
  class ModelLoader
    def self.loadModelFile(model, fName, pComponent, modelManager)
      # BUtils = UtilsBase.new(nil)
      file = File.new(fName)
      model.xmlFileName = fName
      model.lastModified = file.mtime
      xmlString = file.read
      xmlDoc = REXML::Document.new xmlString
      depthStack = []
      model.name = AttributeLoader.init(xmlDoc.root).names("name").get
      model.feature_group = AttributeLoader.init(xmlDoc.root).names("feature_group").get
      model.data_node = xmlDoc.root

      xmlDoc.root.elements.each("description") do |desc|
        model.description = desc.text
      end

      xmlDoc.root.elements.each("var_group") do |vargXML|
        # puts "loading var group"
        newVGroup = CodeStructure::CodeElemVarGroup.new
        CodeElemLoader.load(newVGroup, vargXML, model)
        newVGroup.name = AttributeLoader.init.xml(vargXML).model(model).names("name").get

        loadVarGroupNode(newVGroup, vargXML, pComponent, model)
        model.varGroup = newVGroup
      end

      xmlDoc.root.elements.each("filters") do |pXml|
        DataFilterLoader.load_data_filter(model.data_filter, pXml)
      end

      xmlDoc.root.elements.each("include") do |incXml|
        if !incXml.attributes["path"].nil?
          iPath = incXml.attributes["path"]
        else
          iPath = String.new
        end

        if !incXml.attributes["name"].nil?
          model.add_include(iPath, incXml.attributes["name"], '"')
        else
          model.add_include(iPath, incXml.attributes["lname"], "<")
        end
      end

      xmlDoc.root.elements.each("gen_class") do |genCXML|
        cls = CodeStructure::CodeElemClassSpec.new(cls, model, model)

        ClassLoader.loadClass(pComponent, cls, genCXML, modelManager)
      end

      # Load class groups
      xmlDoc.root.elements.each("class_group_ref") do |nodeXml|
        cGroup = ClassGroups.get(nodeXml.attributes["name"])
        cgRef = CodeStructure::CodeElemClassGroupRef.new(model)
        ClassGroupRefLoader.loadClassGroupRef(cgRef, nodeXml)

        if !cGroup.nil?
          cGroup.data_node.elements.each("gen_class") do |genCXML|
            cls = CodeStructure::CodeElemClassSpec.new(cls, model, model)
            cls.class_group_ref = cgRef
            ClassLoader.loadClass(pComponent, cls, genCXML, modelManager)
          end
        end
      end
    end

    # Loads a group node from an XML template vargroup node
    def self.loadVarGroupNode(vgNode, vgXML, pComponent, parent_elem)
      CodeElemLoader.load(vgNode, vgXML, parent_elem)
      vgNode.name = AttributeLoader.init.xml(vgXML).names("name").get

      for varElem in vgXML.elements
        if varElem.name.downcase == "variable" || varElem.name.downcase == "var"
          VariableLoader.loadVariableNode(varElem, vgNode, pComponent)
        elsif varElem.name == "var_group"
          newVG = CodeStructure::CodeElemVarGroup.new
          loadVarGroupNode(newVG, varElem, pComponent, vgNode)
          vgNode.varGroups << newVG
        end
      end
    end
  end
end
