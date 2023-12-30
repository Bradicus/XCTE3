##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require 'filters/paging_filter'
require 'filters/sort_filter'
require 'filters/search_filter'
require 'filters/static_filter'

module Filters
  class DataFilter
    attr_accessor :paging, :search, :sort, :static_filters

    def initialize
      @paging = PagingFilter.new
      @search = SearchFilter.new
      @sort = SortFilter.new
      @static_filters = []
    end
  end
end
