##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require 'code_elem_project'
require 'code_structure/code_elem_build_var'
require 'code_structure/code_elem_action'
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
        genC.feature_group = genC.class_group_ref.feature_group
        genC.variant = genC.class_group_ref.variant
      end

      CodeElemLoader.load(genC, genCXml, pComponent) 

      if genC.lang_only.length > 0 && !genC.lang_only.include?(pComponent.language)
        return nil
      end         

      genC.feature_group = 
        AttributeLoader.init.xml(genCXml).names('feature_group').model(genC.model).default(genC.feature_group).get
      genC.variant = 
        AttributeLoader.init.xml(genCXml).names('variant').model(genC.model).default(genC.variant).get

      # Must be loaded after feature group because of build vars
      genC.name = AttributeLoader.init.xml(genCXml).cls(genC).model(genC.model).names('name').get  
      genC.plug_name = AttributeLoader.init.xml(genCXml).names('type').cls(genC).get
      genC.namespace = NamespaceUtil.loadNamespaces(genCXml, pComponent)
      genC.interface_namespace = CodeStructure::CodeElemNamespace.new(genCXml.attributes['interface_namespace'])
      genC.interface_path = genCXml.attributes['interface_path']
      genC.test_namespace = CodeStructure::CodeElemNamespace.new(genCXml.attributes['test_namespace'])
      genC.test_path = AttributeLoader.init.xml(genCXml).names('test_path').get
      genC.language = genCXml.attributes['language']
      genC.path = AttributeLoader.init.xml(genCXml).names('path').model(genC.model).cls(genC).default('').get
      genC.var_prefix = AttributeLoader.init.xml(genCXml).names('var_prefix').get

      # Add base namespace to class namespace lists
      if !pComponent.nil? && !pComponent.namespace.ns_list.empty?
        genC.namespace.ns_list = pComponent.namespace.ns_list + genC.namespace.ns_list
      end

      genCXml.elements.each('base_class') do |bcXml|
        baseClass = ClassRefLoader.loadClassRef(bcXml, genCXml, pComponent)

        # bcXml.elements.each('tpl_param') do |tplXml|
        #   tplParam = CodeStructure::CodeElemClassRef.new(bcXml, pComponent)
        #   tplParam.name = tplXml.attributes['name']
        #   baseClass.templateParams << tplParam
        # end

        genC.base_classes << baseClass
      end

      genCXml.elements.each('pre_def') do |pdXml|
        genC.preDefs << pdXml.attributes['name']
      end

      genCXml.elements.each('data_class') do |dcXml|
        genC.data_class = ClassRefLoader.loadClassRef(dcXml, genCXml, pComponent, genC.model)
      end

      genCXml.elements.each('interface') do |ifXml|
        intf = CodeStructure::CodeElemClassSpec.new(CodeStructure::CodeElemModel.new, nil, pComponent, false)
        intf.name = ifXml.attributes['name']
        intf.namespace = NamespaceUtil.loadNamespaces(ifXml, pComponent)
        genC.interfaces << intf
      end

      genCXml.elements.each('function') do |funXml|
        newFun = CodeStructure::CodeElemFunction.new(genC)
        loadTemplateFunctionNode(genC, newFun, funXml, pComponent)
        genC.functions << newFun
      end

      genCXml.elements.each('empty_function') do |funXml|
        newFun = CodeStructure::CodeElemFunction.new(genC)
        loadEmptyFunctionNode(newFun, genC, funXml, pComponent)
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
        act = CodeStructure::CodeElemAction.new
        act.name = AttributeLoader.init.xml(xmlNode).names('name').model(genC.model).cls(genC).get
        act.link = AttributeLoader.init.xml(xmlNode).names('link').model(genC.model).cls(genC).get
        act.trigger = AttributeLoader.init.xml(xmlNode).names('trigger').model(genC.model).cls(genC).get
        genC.actions.push(act)
      end

      modelManager.list << genC
      genC.model.add_class genC

      if genC.interface_namespace.hasItems?
        intf = processInterface(genC)
        modelManager.list << intf
        genC.model.add_class intf
      end

      return unless genC.test_namespace.hasItems?

      intf = ClassLoader.processTests(genC)
      modelManager.list << intf
      genC.model.add_class genC

      return genC

      # puts "Loaded clss note with function count " + genC.functions.length.to_s
    end

    # Loads a template function element from an XML template function node
    def self.loadTemplateFunctionNode(genC, fun, tmpFunXML, pComponent)
      CodeElemLoader.load(fun, tmpFunXML, genC)
      fun.name = AttributeLoader.init.xml(tmpFunXML).model(genC.model).names('name').get 
      
      fun.role = AttributeLoader.init.xml(tmpFunXML).names('role').cls(genC).get
      # puts "Loading function: " + fun.name
      fun.isTemplate = true
      fun.isInline = (tmpFunXML.attributes['inline'] == 'true')

      varArray = []
      tmpFunXML.elements.each('param') do |refXml|
        VariableLoader.loadVariableNode(refXml, fun, pComponent)
      end
    end

    # Loads a function element from an XML function node
    def self.loadEmptyFunctionNode(newFun, cls, funXml, pComponent)
      CodeElemLoader.load(newFun, funXml, cls)  
      newFun.name = AttributeLoader.init.xml(xml_node).model(cls.model).names('name').get     
      
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

          CodeElemLoader.load(newFun.parameters, funElemXML, cls)  
          newFun.name = AttributeLoader.init.xml(xml_node).model(cls.model).names('name').get     

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

    def self.loadList(str, separator)
      return str.split(separator).map!(&:trim)
    end

    def self.processInterface(cls)
      intf = CodeStructure::CodeElemClassSpec.new(cls, cls.model, cls.parent_elem)
      intf.namespace = CodeStructure::CodeElemNamespace.new(cls.interface_namespace.get('.'))
      intf.path = cls.interface_path
      intf.functions = cls.functions
      intf.language = cls.language
      intf.plug_name = 'interface'
      intf.parent_elem = cls
      intf.model = cls.model

      return intf
    end

    def self.processTests(cls)
      intf = CodeStructure::CodeElemClassSpec.new(cls, cls.model, cls.parent_elem)
      intf.namespace = CodeStructure::CodeElemNamespace.new(cls.test_namespace.get('.'))
      intf.path = cls.test_path
      intf.language = cls.language
      intf.plug_name = 'test_engine'
      intf.parent_elem = cls
      intf.model = cls.model

      return intf
    end
  end
end
