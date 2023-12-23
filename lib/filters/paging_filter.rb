##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

module Filters
  class PagingFilter
    attr_accessor :page_sizes, :pager, :page_size_default

    def initialize
      @pager = 'none'
      @page_sizes = []
      @page_size_default = 10
    end
  end
end
