##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require 'code_elem_project'
require 'code_elem_build_var'
require 'code_elem_action'
require 'data_loading/variable_loader'
require 'data_loading/attribute_loader'
require 'data_loading/attribute_loader'
require 'data_loading/namespace_util'
require 'data_loading/class_ref_loader'
require 'data_loading/data_filter_loader'
require 'rexml/document'

module DataLoading
  class ClassLoader
    # Loads a class from an xml node
    def self.loadClass(pComponent, genC, genCXml, modelManager)
      if !genC.class_group_ref.nil?
        genC.featureGroup = genC.class_group_ref.featureGroup
        genC.variant = genC.class_group_ref.variant
      end

      genC.xmlElement = genCXml

      genC.featureGroup = AttributeLoader.init
                                         .xml(genCXml).names('feature_group').model(genC.model).default(genC.featureGroup).get
      genC.variant = AttributeLoader.init
                                    .xml(genCXml).names('variant').model(genC.model).default(genC.variant).get

      genC.plugName = AttributeLoader.init.xml(genCXml).names('type').cls(genC).get
      genC.className = AttributeLoader.init.xml(genCXml).names('name').model(genC.model).cls(genC).get
      genC.namespace = NamespaceUtil.loadNamespaces(genCXml, pComponent)
      genC.interfaceNamespace = CodeStructure::CodeElemNamespace.new(genCXml.attributes['interface_namespace'])
      genC.interfacePath = genCXml.attributes['interface_path']
      genC.testNamespace = CodeStructure::CodeElemNamespace.new(genCXml.attributes['test_namespace'])
      genC.testPath = AttributeLoader.init.xml(genCXml).names('test_path').get
      genC.language = genCXml.attributes['language']
      genC.path = AttributeLoader.init.xml(genCXml).names('path').model(genC.model).cls(genC).default('').get
      genC.varPrefix = AttributeLoader.init.xml(genCXml).names('var_prefix').get

      # Add base namespace to class namespace lists
      if !pComponent.nil? && !pComponent.namespace.nsList.empty?
        genC.namespace.nsList = pComponent.namespace.nsList + genC.namespace.nsList
      end

      genCXml.elements.each('base_class') do |bcXml|
        baseClass = CodeStructure::CodeElemClassSpec.new(CodeStructure::CodeElemModel.new, nil, pComponent, false)
        baseClass.name = bcXml.attributes['name']
        baseClass.namespace = NamespaceUtil.loadNamespaces(bcXml, pComponent)

        bcXml.elements.each('tpl_param') do |tplXml|
          tplParam = CodeStructure::CodeElemClassSpec.new(CodeStructure::CodeElemModel.new, nil, pComponent, false)
          tplParam.name = tplXml.attributes['name']
          baseClass.templateParams << tplParam
        end

        genC.baseClasses << baseClass
      end

      genCXml.elements.each('pre_def') do |pdXml|
        genC.preDefs << pdXml.attributes['name']
      end

      genCXml.elements.each('data_class') do |dcXml|
        genC.dataClass = ClassRefLoader.loadClassRef(dcXml, genCXml, pComponent, genC.model)
      end

      genCXml.elements.each('interface') do |ifXml|
        intf = CodeStructure::CodeElemClassSpec.new(CodeStructure::CodeElemModel.new, nil, pComponent, false)
        intf.name = ifXml.attributes['name']
        intf.namespace = NamespaceUtil.loadNamespaces(ifXml, pComponent)
        genC.interfaces << intf
      end

      genCXml.elements.each('function') do |funXml|
        newFun = CodeStructure::CodeElemFunction.new(genC)
        loadTemplateFunctionNode(genC, newFun, funXml)
        genC.functions << newFun
      end

      genCXml.elements.each('empty_function') do |funXml|
        newFun = CodeStructure::CodeElemFunction.new(genC)
        loadEmptyFunctionNode(newFun, funXml, pComponent)
        newFun.isTemplate = false
        genC.functions << newFun
      end

      genCXml.elements.each('include') do |incXml|
        if !incXml.attributes['path'].nil?
          iPath = incXml.attributes['path']
        else
          iPath = String.new
        end

        if !incXml.attributes['name'].nil?
          genC.addInclude(iPath, incXml.attributes['name'], '"')
        else
          genC.addInclude(iPath, incXml.attributes['lname'], '<')
        end
      end

      # Load uses
      genCXml.elements.each('use') do |useXml|
        if !useXml.attributes['name'].nil?
          genC.addUse(useXml.attributes['name'])
        end
      end

      if !pComponent.nil?
        genCXml.elements.each('use-' + pComponent.language) do |useXml|
          if !useXml.attributes['name'].nil?
            genC.addUse(useXml.attributes['name'])
          end
        end
      end

      # Load uses
      genCXml.elements.each('actions/action') do |xmlNode|
        act = CodeElemAction.new
        act.name = AttributeLoader.init.xml(xmlNode).names('name').model(genC.model).cls(genC).get
        act.link = AttributeLoader.init.xml(xmlNode).names('link').model(genC.model).cls(genC).get
        act.trigger = AttributeLoader.init.xml(xmlNode).names('trigger').model(genC.model).cls(genC).get
        genC.actions.push(act)
      end

      modelManager.list << genC
      genC.model.classes << genC

      if genC.interfaceNamespace.hasItems?
        intf = processInterface(genC, model, pComponent)
        modelManager.list << intf
        genC.model.classes << intf
      end

      return unless genC.testNamespace.hasItems?

      intf = ClassLoader.processTests(genC, model, pComponent)
      modelManager.list << intf
      genC.model.classes << genC

      # puts "Loaded clss note with function count " + genC.functions.length.to_s
    end

    # Loads a template function element from an XML template function node
    def self.loadTemplateFunctionNode(genC, fun, tmpFunXML)
      fun.loadAttributes(tmpFunXML)
      fun.name = tmpFunXML.attributes['name']
      fun.role = AttributeLoader.init.xml(tmpFunXML).names('role').cls(genC).get
      # puts "Loading function: " + fun.name
      fun.isTemplate = true
      fun.isInline = (tmpFunXML.attributes['inline'] == 'true')

      varArray = []
      tmpFunXML.elements.each('var_ref') do |refXml|
        ref = genC.findVar(refXml.attributes['name'])
        if ref
          fun.variableReferences << ref
        end
      end
    end

    # Loads a function element from an XML function node
    def self.loadEmptyFunctionNode(newFun, funXml, pComponent)
      newFun.loadAttributes(funXml)
      newFun.name = funXml.attributes['name']
      newFun.isInline = (funXml.attributes['inline'] == 'true')

      if !funXml.attributes['const'].nil? && funXml.attributes['const'].casecmp('true')
        newFun.isConst = true
      end
      if !funXml.attributes['static'].nil? && funXml.attributes['static'].casecmp('true')
        newFun.isStatic = true
      end
      if !funXml.attributes['visibility'].nil?
        newFun.visibility = funXml.attributes['visibility']
      end
      if !funXml.attributes['virtual'].nil? && funXml.attributes['virtual'].casecmp('true')
        newFun.isVirtual = true
      end

      for funElemXML in funXml.elements
        if funElemXML.name == 'parameters'
          newFun.parameters.loadAttributes(funElemXML)
          for paramXML in funElemXML.elements
            VariableLoader.loadVariableNode(paramXML, newFun.parameters, pComponent)
          end
        elsif funElemXML.name == 'return_variable'
          retVar = []
          VariableLoader.loadVariableNode(funElemXML, funXml)
          newFun.returnValue = parentElem.vars[0]
        end
      end
    end

    # Loads a comment from an XML comment node
    def self.loadCommentNode(parXML, section)
      comNode = CodeElemComment.new(parXML.attributes['text'])
      comNode.loadAttributes(parXML)
      section << comNode
    end

    # Loads a br format element from an XML br node
    def self.loadBRNode(brXML, section)
      brk = CodeElemFormat.new("\n")
      brk.loadAttributes(brXML)
      section << brk
    end

    def self.loadList(str, separator)
      return str.split(separator).map!(&:trim)
    end

    def self.processInterface(cls, model, pComponent)
      intf = CodeStructure::CodeElemClassSpec.new(cls, model, pComponent, true)
      intf.namespace = CodeStructure::CodeElemNamespace.new(cls.interfaceNamespace.get('.'))
      intf.path = cls.interfacePath
      intf.functions = cls.functions
      intf.language = cls.language
      intf.plugName = 'interface'
      intf.parentElem = cls
      intf.model = model
    end

    def self.processTests(cls, model, pComponent)
      intf = CodeStructure::CodeElemClassSpec.new(cls, model, pComponent, true)
      intf.namespace = CodeStructure::CodeElemNamespace.new(cls.testNamespace.get('.'))
      intf.path = cls.testPath
      intf.language = cls.language
      intf.plugName = 'test_engine'
      intf.parentElem = cls
      intf.model = model

      return intf
    end
  end
end
