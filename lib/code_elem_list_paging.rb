##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

#

module CodeElement
  class CodeElemListPaging
    attr_accessor :sort, :search_by, :page_filter

    @sort
    @search_by = []
    @page_filter
  end
end
