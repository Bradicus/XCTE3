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
  class MethodPagerequestFilter < XCTEPlugin
    def initialize
      @name = "method_pagerequest_filter"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, fun)
      bld.add("PageRequest getPageRequest(Long pageNum, Long pageSize, Sort sort)")
    end

    def process_dependencies(cls, bld, fun)
    end

    def get_body(cls, bld, fun)
      bld.startFunction("public static PageRequest getPageRequest(Long pageNum, Long pageSize, Sort sort)")

      bld.add "PageRequest pageRequest = null;"

      bld.startBlock("if (pageNum != null && pageSize > 0)")
      bld.add "pageRequest = PageRequest.of(pageNum.intValue(), pageSize.intValue());"
      bld.midBlock "else"
      bld.add "pageRequest = PageRequest.of(0, Integer.MAX_VALUE);"
      bld.endBlock

      bld.startBlock("if (sort != null)")
      bld.add "pageRequest = pageRequest.withSort(sort);"
      bld.endBlock

      bld.add "return pageRequest;"

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodPagerequestFilter.new)
