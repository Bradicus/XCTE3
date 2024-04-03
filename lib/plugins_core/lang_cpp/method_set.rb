##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a set meathod for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'

module XCTECpp
  class MethodSet < XCTEPlugin
    def initialize
      @name = 'method_set'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's set method
    def get_declaration(varSec, bld)
      return unless varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && varSec.genSet == true

      funName = Utils.instance.style_as_function('set ' + varSec.name)
      varName = Utils.instance.get_styled_variable_name(varSec)
      inVarName = CodeNameStyling.getStyled('new ' + varSec.name, Utils.instance.langProfile.variableNameStyle)
      bld.add('void ' + funName)
      bld.same_line('(' + Utils.instance.get_type_name(varSec) + ' ' + inVarName)
      bld.same_line(")\t{ " + varName + ' = ' + inVarName + '; };')
    end

    # Returns definition string for this class's set method
    def render_function(codeClass, bld)
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodSet.new)
