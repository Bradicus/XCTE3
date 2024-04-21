##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require "x_c_t_e_plugin"
require "plugins_core/lang_cpp/x_c_t_e_cpp"

module XCTECpp
  class XCTECpp::MethodOperatorEqualTo < XCTEPlugin
    def initialize
      @name = "method_operator_equal_to"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's equality assignment operator
    def render_declaration(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      bld.add("bool operator==" << "(const " << cls.name)
      bld.same_line(" src" << cls.name << ") const;")
    end

    def process_dependencies(cls, bld, funItem)
    end

    # Returns definition string for this class's equality assignment operator
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      longArrayFound = false
      seperator = ""

      styledCName = cls.name

      bld.add("/**")
      bld.add("* Returns whether or not two objecs are equal")
      bld.add("*/")
      bld.start_class("bool " + styledCName + " :: operator==" + "(const " + styledCName + " src" + styledCName + ") const")

      bld.add("return(")
      bld.indent

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.isStatic && Utils.instance.is_primitive(var) && (var.arrayElemCount.to_i == 0) # Array of primitives
          bld.add(seperator << Utils.instance.get_styled_variable_name(var) << " == ")
          bld.same_line("src" << styledCName << ".")
          bld.same_line(Utils.instance.get_styled_variable_name(var))

          seperator = "&& "
        end
      }))

      bld.unindent

      bld.add(");")
      bld.end_block
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodOperatorEqualTo.new)
