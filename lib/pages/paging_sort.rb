##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

#

module Pages
  class PagingSort
    attr_accessor :defaultSortColumn, :defaultSortDirection, :sortableColumns

    @defaultSortColumn
    @defaultSortDirection
    @sortableColumns

    def initialize
      @sortableColumns = Array.new
    end
  end
end
