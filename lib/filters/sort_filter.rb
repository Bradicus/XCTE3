##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

module Filters
  class SortFilter
    attr_accessor :default_sort_column, :default_sort_direction, :sortable_columns

    def initialize
      @sortable_columns = []
    end
  end
end
