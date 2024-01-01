##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class group information from an XML node

require 'code_elem_project'
require 'code_elem_build_var'
require 'data_loading/attribute_loader'
require 'data_loading/class_ref_loader'
require 'filters/data_filter'
require 'filters/sort_filter'
require 'filters/search_filter'
require 'filters/static_filter'
require 'rexml/document'

module DataLoading
  class DataFilterLoader
    def self.load_data_filter(data_filter, page_node)
      if page_node.nil?
        return nil
      end

      page_node.elements.each('sort') do |xml_node|
        data_filter.sort = Filters::SortFilter.new
        data_filter.sort.default_sort_column = AttributeLoader.init(xml_node).names('defaultSortColumn').get
        data_filter.sort.default_sort_direction = AttributeLoader.init(xml_node).names('defaultSortDirection').get
        data_filter.sort.sortable_columns =
          AttributeLoader.init(xml_node).names('sortableColumns').arrayDelim(',').get
      end

      page_node.elements.each('search') do |xml_node|
        data_filter.search = Filters::SearchFilter.new
        data_filter.search.type = AttributeLoader.init(xml_node).names('type').get
        data_filter.search.name = AttributeLoader.init(xml_node).names('name').get
        data_filter.search.columns =
          AttributeLoader.init(xml_node).names('columns').arrayDelim(',').get
      end

      page_node.elements.each('page_filter') do |xml_node|
        data_filter.paging.page_sizes = AttributeLoader.init(xml_node).arrayDelim(',').names('sizes').get
        data_filter.paging.page_size_default = AttributeLoader.init(xml_node).names('default').get
        data_filter.paging.pager = AttributeLoader.init(xml_node).names('pager').get
      end

      page_node.elements.each('static_filter') do |xml_node|
        static_filter = Filters::StaticFilter.new
        static_filter.column = AttributeLoader.init(xml_node).names('column').get
        static_filter.value = AttributeLoader.init(xml_node).names('value').get
        data_filter.static_filters.push(static_filter)
      end
    end
  end
end
