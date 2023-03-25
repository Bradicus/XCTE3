##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "rexml/document"
require "data_loading/attribute_loader"

module DataLoading
  class NamespaceUtil
    # Load a list of namespaces on a node
    def self.loadNamespaces(xml, pComponent)
      return CodeStructure::CodeElemNamespace.new(
               AttributeLoader.init(xml).names(Array["ns", "namespace"]).get()
             )
    end
  end
end
