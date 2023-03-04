##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class reference information form an XML node

require "rexml/document"
require "code_elem_class_ref"
require "data_loading/attribute_loader"

module DataLoading
  class ClassRefLoader
    def self.loadClassRef(xmlNode, parentElem, pComponent)
      cRef = CodeStructure::CodeElemClassRef.new(parentElem, pComponent)

      cRef.namespaces = NamespaceUtil.loadNamespaces(xmlNode, pComponent)

      cRef.className = AttributeLoader.init().xml(xmlNode).names("cname").get()
      cRef.pluginName = AttributeLoader.init().xml(xmlNode).names("plug").get()

      return cRef
    end
  end
end
