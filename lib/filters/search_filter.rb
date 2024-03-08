##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

module Filters
  class SearchFilter
    attr_accessor :columns, :name, :type

    def initialize
      @name = nil
      @type = 'shared'
      @columns = []
    end

    def get_name()
      if @name.nil?
        if @type == 'shared'
          return 'searchValue'
        else
          return @columns.join(' ')
        end
      end

      return @name
    end
  end
end
