##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "rexml/document"
require "data_processing/attribute_util"

module DataProcessing
  class NamespaceUtil
    # Load a list of namespaces on a node
    def self.loadNamespaces(xml, pComponent)
      return CodeStructure::CodeElemNamespace.new(AttributeUtil.loadAttribute(xml, Array["ns", "namespace"], pComponent.language, "."))
    end
  end
end
