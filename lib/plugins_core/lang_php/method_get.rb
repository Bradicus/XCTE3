##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a get meathod for a class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_php/x_c_t_e_php.rb'

class XCTEPhp::MethodGet < XCTEPlugin

  def initialize
    @name = "method_get"
    @language = "php"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's get method
  def get_declaration(codeClass, cfg)
    return ""
  end

  # Returns definition string for this class's set method
  def render_function(codeClass, outCode)
    
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

	outCode.add
	
    for varSec in varArray
      if varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && varSec.genGet == "true"
        if !varSec.isPointer
          outCode.add("    public function get" << XCTEPhp::Utils::getCapitalizedFirst(varSec.name))
          outCode.add("() \t{ return($this->" << varSec.name << "); }")
        end

      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        outCode.iadd(1, XCTEPhp::Utils::getComment(varSec))
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        outCode.add(varSec.formatText)
      end
    end
	
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodGet.new)
