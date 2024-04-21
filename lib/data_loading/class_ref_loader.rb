##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class reference information form an XML node

require "rexml/document"
require "code_structure/code_elem_class_ref"
require "data_loading/attribute_loader"

module DataLoading
  class ClassRefLoader
    def self.loadClassRef(xml_node, parentElem, pComponent, model = nil)
      cRef = CodeStructure::CodeElemClassRef.new(parentElem, pComponent)

      cRef.namespace = NamespaceUtil.loadNamespaces(xml_node, pComponent)

      cRef.model_name = AttributeLoader.init.xml(xml_node).model(model).names("name").required.get
      cRef.plugin_name = AttributeLoader.init.xml(xml_node).model(model).names("plugin").default("class_standard").get

      xml_node.elements.each("tpl_param") do |tplXml|
        tplParam = self.loadClassRef(tplXml, xml_node, pComponent)
        cRef.template_params << tplParam
      end

      return cRef
    end
  end
end
