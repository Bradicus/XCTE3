##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require "filters/paging_filter"
require "filters/sort_filter"
require "filters/search_filter"
require "filters/static_filter"

module Filters
  class DataFilter
    attr_accessor :paging, :search_filter, :sort, :static_filters

    def initialize
      @paging = PagingFilter.new
      @search_filter = nil
      @sort = SortFilter.new
      @static_filters = []
    end

    def has_non_paging_filters?
      return !@static_filters.empty? || has_search_filter?
    end

    def has_search_filter?
      return !search_filter.nil?
    end

    def has_shared_filter?
      return has_search_filter? && search_filter.type == "shared"
    end

    def get_search_cols
      if search_filter.nil?
        return []
      end

      return search_filter.columns
    end

    def get_search_fun_name
      return "search for " + get_search_cols.join(" ")
    end
  end
end
