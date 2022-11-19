##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a set meathod for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

module XCTECpp
  class MethodSet < XCTEPlugin
    def initialize
      @name = "method_set"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's set method
    def get_declaration(varSec, cfg, bld)
      if varSec.elementId == CodeElem::ELEM_VARIABLE && varSec.genSet == true
        funName = Utils.instance.getStyledFunctionName("set " + varSec.name)
        varName = Utils.instance.getStyledVariableName(varSec)
        inVarName = CodeNameStyling.getStyled("new " + varSec.name, Utils.instance.langProfile.variableNameStyle)
        bld.add("void " + funName)
        bld.sameLine("(" + Utils.instance.getTypeName(varSec) + " " + inVarName)
        bld.sameLine(")\t{ " + varName + " = " + inVarName + "; };")
      end
    end

    # Returns definition string for this class's set method
    def get_definition(codeClass, cfg, bld)
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodSet.new)
