##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require 'code_structure/code_elem_types'

module CodeStructure
  class CodeElem
    attr_accessor :element_id, :name, :display_name, :description, :visibility, :parent_elem, 
            :data_node, :lang_only, :os_only
    
    def initialize(element_id, parent_elem)
      @element_id = element_id
      @parent_elem = parent_elem

      @name = nil
      @display_name = nil
      @description = nil
      @visibility = 'public'
      @parent_elem = nil
      @data_node = nil
      @lang_only = []	# What languages this node is limited to
      @os_only = []	# What os's this node is limited to
    end
  end
end

