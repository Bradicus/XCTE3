##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require 'code_elem_project'
require 'data_loading/attribute_util'
require 'data_loading/namespace_util'
require 'data_loading/variable_loader'
require 'data_loading/class_loader'
require 'data_loading/class_group_ref_loader'
require 'code_elem_class_group_ref'
require 'rexml/document'
require 'class_groups'
require 'utils_base'

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
      model.name = AttributeLoader.init(xmlDoc.root).names('name').get
      model.featureGroup = AttributeLoader.init(xmlDoc.root).names('feature_group').get
      model.xmlElement = xmlDoc.root

      xmlDoc.root.elements.each('derived') do |derived|
        model.derivedFrom = AttributeUtil.loadAttribute(derived, 'from', pComponent)
        model.modelSet = AttributeUtil.loadAttribute(derived, 'model_set', pComponent)
        Log.error('No model set for derived class in ' + mdoel.name) if model.modelSet.nil?
      end

      xmlDoc.root.elements.each('description') do |desc|
        model.description = desc.text
      end

      xmlDoc.root.elements.each('var_group') do |vargXML|
        # puts "loading var group"
        newVGroup = CodeStructure::CodeElemVarGroup.new
        newVGroup.loadAttributes(vargXML)

        loadVarGroupNode(newVGroup, vargXML, pComponent)
        model.varGroup = newVGroup
      end

      xmlDoc.root.elements.each('filters') do |pXml|
        DataFilterLoader.load_data_filter(model.data_filter, pXml)
      end

      xmlDoc.root.elements.each('gen_class') do |genCXML|
        cls = CodeStructure::CodeElemClassSpec.new(model, model, pComponent, true)
        cls.loadAttributes(genCXML)

        if cls.langInclude.length > 0
          ClassLoader.loadClass(pComponent, cls, genCXML, modelManager) if cls.langInclude.include?(pComponent.language)
        else
          ClassLoader.loadClass(pComponent, cls, genCXML, modelManager)
        end
      end

      # Load class groups
      xmlDoc.root.elements.each('class_group_ref') do |nodeXml|
        cGroup = ClassGroups.get(nodeXml.attributes['name'])
        cgRef = CodeStructure::CodeElemClassGroupRef.new
        ClassGroupRefLoader.loadClassGroupRef(cgRef, nodeXml)

        if !cGroup.nil?
          cGroup.xmlElement.elements.each('gen_class') do |genCXML|
            cls = CodeStructure::CodeElemClassSpec.new(model, model, pComponent, true)
            cls.classGroupRef = cgRef
            cls.loadAttributes(genCXML)

            if cls.langInclude.length > 0
              if cls.langInclude.include?(pComponent.language)
                ClassLoader.loadClass(pComponent, cls, genCXML, modelManager)
              end
            else
              ClassLoader.loadClass(pComponent, cls, genCXML, modelManager)
            end
          end
        end
      end
    end

    def self.loadClassGenNode(model, genCXML, pComponent, cgRefXml)
      cls = CodeStructure::CodeElemClassSpec.new(model, model, pComponent, true)
      cgRef = CodeStructure::CodeElemClassGroupRef.new
      ClassGroupRefLoader.loadClassGroupRef(cgRef, cgRefXml)

      ClassLoader.loadClass(pComponent, cls, genCXML)
      ClassModelManager.list << cls
      model.classes << cls

      if cls.interfaceNamespace.hasItems?
        intf = processInterface(cls, model, pComponent)
        ClassModelManager.list << intf
        model.classes << intf
      end

      return unless cls.testNamespace.hasItems?

      intf = ClassLoader.processTests(cls, model, pComponent)
      ClassModelManager.list << intf
      model.classes << cls
    end

    # Loads a group node from an XML template vargroup node
    def self.loadVarGroupNode(vgNode, vgXML, pComponent)
      vgNode.name = vgXML.attributes['name'] if !vgXML.attributes['name'].nil?

      # puts "[ElemClass::loadVarGroupNode] loading var node "

      for varElem in vgXML.elements
        if varElem.name.downcase == 'variable' || varElem.name.downcase == 'var'
          VariableLoader.loadVariableNode(varElem, vgNode, pComponent)
        elsif varElem.name == 'var_group'
          newVG = CodeStructure::CodeElemVarGroup.new
          newVG.loadAttributes(varElem)
          loadVarGroupNode(newVG, varElem, pComponent)
          vgNode.varGroups << newVG
        elsif varElem.name == 'comment'
          loadCommentNode(varElem, vgNode.vars)
        elsif varElem.name == 'br'
          #          loadBRNode(varElem, vgNode.vars)
        end
      end
    end
  end
end
