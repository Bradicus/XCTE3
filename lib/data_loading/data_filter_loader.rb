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

      page_node.elements.each('sort') do |xmlNode|
        data_filter.sort = Filters::SortFilter.new
        data_filter.sort.default_sort_column = AttributeLoader.init(xmlNode).names('defaultSortColumn').get
        data_filter.sort.default_sort_direction = AttributeLoader.init(xmlNode).names('defaultSortDirection').get
        data_filter.sort.sortable_columns =
          AttributeLoader.init(xmlNode).names('sortableColumns').arrayDelim(',').get
      end

      page_node.elements.each('search') do |xmlNode|
        data_filter.search = Filters::SearchFilter.new
        data_filter.search.type = AttributeLoader.init(xmlNode).names('type').get
        data_filter.search.columns =
          AttributeLoader.init(xmlNode).names('columns').arrayDelim(',').get
      end

      page_node.elements.each('page_filter') do |xmlNode|
        data_filter.paging.page_sizes = AttributeLoader.init(xmlNode).arrayDelim(',').names('sizes').get
        data_filter.paging.page_size_default = AttributeLoader.init(xmlNode).names('default').get
        data_filter.paging.pager = AttributeLoader.init(xmlNode).names('pager').get
      end

      page_node.elements.each('static_filter') do |xmlNode|
        static_filter = Filters::StaticFilter.new
        static_filter.column = AttributeLoader.init(xmlNode).names('column').get
        static_filter.value = AttributeLoader.init(xmlNode).names('value').get
        data_filter.static_filter = static_filter
      end
    end
  end
end
