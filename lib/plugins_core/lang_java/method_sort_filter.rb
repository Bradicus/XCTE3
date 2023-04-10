##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "code_name_styling.rb"
require "plugins_core/lang_java/utils.rb"

module XCTEJava
  class MethodSortFilter < XCTEPlugin
    def initialize
      @name = "method_sort_filter"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, fun)
      bld.add("Sort getSort(String sortBy, String sortOrder);")
    end

    def process_dependencies(cls, bld, fun)
    end

    def get_body(cls, bld, fun)
      bld.startFunction("public static Sort getSort(String sortBy, String sortOrder)")
      bld.add "Sort sort = null;"
      bld.startBlock("if (sortBy != null)")
      bld.add "sort = Sort.by(sortBy);"
      bld.startBlock("if (sortOrder != null)")
      bld.startBlock('if (sortOrder.equals("asc"))')
      bld.add "sort = sort.ascending();"
      bld.midBlock "else"
      bld.add "sort = sort.descending();"
      bld.endBlock
      bld.endBlock
      bld.endBlock
      bld.add "return sort;"
      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodSortFilter.new)
