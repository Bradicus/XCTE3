##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class group information from an XML node

require "code_elem_project.rb"
require "code_elem_build_var.rb"
require "data_loading/attribute_loader"
require "data_loading/class_ref_loader"
require "pages/paging"
require "pages/paging_sort"
require "pages/paging_search"
require "rexml/document"

module DataLoading
  class PagingLoader
    def self.loadPaging(paging, pageNode)
      if pageNode != nil
        paging.pager = AttributeLoader.init(pageNode).names("pager").get()

        pageNode.elements.each("sort") { |xmlNode|
          paging.sort = Pages::PagingSort.new
          paging.sort.defaultSortColumn = AttributeLoader.init(xmlNode).names("defaultSortColumn").get()
          paging.sort.defaultSortDirection = AttributeLoader.init(xmlNode).names("defaultSortDirection").get()
          paging.sort.sortableColumns =
            AttributeLoader.init(xmlNode).names("sortableColumns").arrayDelim(",").get()
        }

        pageNode.elements.each("search") { |xmlNode|
          paging.search = Pages::PagingSearch.new
          paging.search.type = AttributeLoader.init(xmlNode).names("type").get()
          paging.search.columns =
            AttributeLoader.init(xmlNode).names("columns").arrayDelim(",").get()
        }

        pageNode.elements.each("page_filter") { |xmlNode|
          paging.pageSizes = AttributeLoader.init(xmlNode).arrayDelim(",").names("sizes").get()
          paging.pageSizeDefault = AttributeLoader.init(xmlNode).names("default").get()
        }

        #        paging.xmlElement = pageNode
      end
    end
  end
end
