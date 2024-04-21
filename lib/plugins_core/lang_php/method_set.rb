##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a set meathod for a class

require "x_c_t_e_plugin"
require "plugins_core/lang_php/x_c_t_e_php"

class XCTEPhp::MethodSet < XCTEPlugin
  def initialize
    @name = "method_set"
    @language = "php"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's set method
  def render_declaration(_codeClass, _cfg)
    return ""
  end

  # Returns definition string for this class's set method
  def render_function(codeClass, outCode)
    varArray = []
    codeClass.getAllVarsFor(varArray)

    for varSec in varArray
      if varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && varSec.genSet == "true"
        if !varSec.isPointer
          outCode.iadd(1, "public function set" << XCTEPhp::Utils.get_capitalized_first(varSec.name))
          outCode.same_line("( $new" << XCTEPhp::Utils.get_capitalized_first(varSec.name))
          outCode.same_line(")\t{ $this->" << varSec.name << " = $new" << XCTEPhp::Utils.get_capitalized_first(varSec.name) << "; }")
        end
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        outCode.iadd(1, XCTEPhp::Utils.get_comment(varSec))
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        outCode.add(varSec.formatText)
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEPhp::MethodSet.new)
