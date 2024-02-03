##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require 'rexml/document'
require 'data_loading/attribute_loader'

module DataLoading
  class CodeElemLoader
    def self.load(code_elem, xml_node, parent_elem)
      code_elem.data_node = xml_node      
      code_elem.parent_elem = parent_elem      
      code_elem.name = AttributeLoader.init.xml(xml_node).names('name').get
      
      if (xml_node.attributes["lang_ignore"] != nil)
        ignoreLangs = xml_node.attributes["lang_ignore"].split(",")
        for iLang in ignoreLangs
          code_elem.lang_only.delete(iLang.strip)
        end
      end

      if (xml_node.attributes["lang_only"] != nil)
        ignoreLangs = xml_node.attributes["lang_only"].split(",")
        code_elem.lang_only = Array.new
        for iLang in ignoreLangs
          code_elem.lang_only << iLang.strip
        end
      end
    end
  end
end
