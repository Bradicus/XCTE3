##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a set meathod for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_php/x_c_t_e_php'

class XCTEPhp::MethodSetEntity < XCTEPlugin
  def initialize
    @name = 'method_set_entity'
    @language = 'php'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's set method
  def get_declaration(_codeClass, _cfg)
    return ''
  end

  # Returns definition string for this class's set method
  def get_definition(codeClass, outCode)
    varArray = []
    codeClass.getAllVarsFor(varArray)

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE && varSec.genSet == 'true'
        if !varSec.isPointer
          outCode.iadd(1, 'public function set' << XCTEPhp::Utils.getCapitalizedFirst(varSec.name))
          outCode.same_line('( $new' << XCTEPhp::Utils.getCapitalizedFirst(varSec.name))
          outCode.same_line(")\t{ $this->" << varSec.name << ' = $new' << XCTEPhp::Utils.getCapitalizedFirst(varSec.name) << '; return $this; }')
        end

      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        outCode.iadd(1, XCTEPhp::Utils.getComment(varSec))
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        outCode.add(varSec.formatText)
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEPhp::MethodSetEntity.new)
