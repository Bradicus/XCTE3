##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

#

require "pages/paging_sort"
require "pages/paging_search"

module Pages
  class Paging
    attr_accessor :sort, :search, :pageSizes, :pageSizeDefault, :pager

    @sort
    @search
    @pageSizes
    @pageSizeDefault
    @pager

    def initialize
      @sort = PagingSort.new
      @search = PagingSearch.new
      @pageSizes = Array.new
      @pager = "none"
      @pageSizeDefault = 10
    end
  end
end
