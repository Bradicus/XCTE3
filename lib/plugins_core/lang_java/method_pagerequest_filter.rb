##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin"
require "code_name_styling"
require "plugins_core/lang_java/utils"

module XCTEJava
  class MethodPagerequestFilter < XCTEPlugin
    def initialize
      @name = "method_pagerequest_filter"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      get_body(fp_params)
    end

    def get_declairation(_cls, bld, _fun)
      bld.add("PageRequest getPageRequest(Integer pageNum, Integer pageSize, Sort sort)")
    end

    def process_dependencies(cls, bld, fun)
    end

    def get_body(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      bld.start_function("public static PageRequest getPageRequest(Integer pageNum, Integer pageSize, Sort sort)")

      bld.add "PageRequest pageRequest = null;"

      bld.start_block("if (pageNum != null && pageSize > 0)")
      bld.add "pageRequest = PageRequest.of(pageNum, pageSize);"
      bld.mid_block "else"
      bld.add "pageRequest = PageRequest.of(0, Integer.MAX_VALUE);"
      bld.end_block

      bld.start_block("if (sort != null)")
      bld.add "pageRequest = pageRequest.withSort(sort);"
      bld.end_block

      bld.add "return pageRequest;"

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodPagerequestFilter.new)
