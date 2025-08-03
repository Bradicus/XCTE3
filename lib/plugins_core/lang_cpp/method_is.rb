##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a is meathod for a class

require "x_c_t_e_plugin"
require "plugins_core/lang_cpp/x_c_t_e_cpp"

module XCTECpp
  class MethodIs < XCTEPlugin
    def initialize
      @name = "method_is"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's is method
    def render_declaration(varSec, bld)
      return unless varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && varSec.has_var_fun?("is")

      funName = Utils.instance.style_as_function("is " + varSec.name)
      varName = Utils.instance.get_styled_variable_name(varSec)
      bld.add("bool " + funName)
      bld.same_line("(" + Utils.instance.get_type_name(varSec) + " " + inVarName)
      bld.same_line(")\t{ return(" + varName + " == " + inVarName + "); };")
    end

    # This method has no body
    def render_function(codeClass, bld)
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodIs.new)
