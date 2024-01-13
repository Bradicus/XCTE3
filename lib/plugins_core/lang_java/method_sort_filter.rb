##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'
require 'code_name_styling'
require 'plugins_core/lang_java/utils'

module XCTEJava
  class MethodSortFilter < XCTEPlugin
    def initialize
      super

      @name = 'method_sort_filter'
      @language = 'java'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      get_body(cls, bld, fun)
    end

    def get_declairation(_cls, bld, _fun)
      bld.add('Sort getSort(String sortBy, Boolean sortAsc);')
    end

    def process_dependencies(cls, bld, fun)
    end

    def get_body(_cls, bld, _fun)
      bld.start_function('public static Sort getSort(String sortBy, Boolean sortAsc)')
      bld.add 'Sort sort = null;'
      bld.start_block('if (sortBy != null)')
      bld.add 'sort = Sort.by(sortBy);'
      bld.start_block('if (sortAsc == true)')
      bld.add 'sort = sort.ascending();'
      bld.mid_block 'else'
      bld.add 'sort = sort.descending();'
      bld.end_block
      bld.end_block
      bld.add 'return sort;'
      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodSortFilter.new)
