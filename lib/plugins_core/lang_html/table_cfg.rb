##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require "plugins_core/lang_html/table_container_types"

module XCTEHtml
  class TableCfg
    attr_accessor  :item_class,  :container_var_name,  :container_type,  :iterator_var_name, :is_observable, :is_embedded
        
    @item_class = nil
    @container_var_name = ""
    @container_type = nil
    @iterator_var_name = ""
    @is_observable = false
    @is_embedded = false
        
    def initialize(item_class, container_var_name, container_type, iterator_var_name, is_observable, is_embedded)
      @item_class = item_class
      @container_var_name = container_var_name
      @container_type = container_type
      @iterator_var_name = iterator_var_name
      @is_observable = is_observable
      @is_embedded = is_embedded
    end

    def is_paged?
        return @container_type == TableContainerTypes::PAGE
    end
  end
end

  