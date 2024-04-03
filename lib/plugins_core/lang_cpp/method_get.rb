##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a get meathod for a class

require "x_c_t_e_plugin"
require "plugins_core/lang_cpp/x_c_t_e_cpp"

module XCTECpp
  class MethodGet < XCTEPlugin
    def initialize
      @name = "method_get"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's get method
    def get_declaration(varSec, bld)
      return unless varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && varSec.genSet == true

      funName = Utils.instance.style_as_function("get " + varSec.name)
      varName = Utils.instance.get_styled_variable_name(varSec)
      bld.add("const " + Utils.instance.get_type_name(varSec) + "& " + funName)
      bld.same_line("() const\t{ return(" + varName + "); };")
    end

    # This method has no body
    def render_function(codeClass, bld)
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodGet.new)
