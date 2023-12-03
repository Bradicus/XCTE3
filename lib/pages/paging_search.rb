##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

#

module Pages
  class PagingSearch
    attr_accessor :type, :columns

    @type
    @columns

    def initialize
      @type = "shared"
      @columns = []
    end
  end
end
