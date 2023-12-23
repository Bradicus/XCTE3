##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

module Filters
  class SearchFilter
    attr_accessor :type, :columns

    def initialize
      @type = 'shared'
      @columns = []
    end
  end
end
