##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a get meathod for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_php/x_c_t_e_php.rb"

class XCTEPhp::MethodGet < XCTEPlugin
  def initialize
    @name = "method_create"
    @language = "php"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's get method
  def render_declaration(codeClass, cfg)
    return ""
  end

  # Returns definition string for this class's set method
  def render_function(codeClass, cfg)
    readDef = String.new
    varArray = Array.new
    codeClass.getAllVarsFor(varArray)

    readDef << "\n"

    readDef << "       public function create() {\n"
    readDef <<
      "$serializer = JMS\Serializer\SerializerBuilder::create()->build();
					"
    "$data = $serializer->deserialize(file_get_contents('php://input'), '', 'json')
			
			foreach ($data as $varName => varValue)
			{
			}"

    "{ return($this->" << varSec.name << "); };\n"

    for varSec in varArray
      if varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && varSec.genSet == "true"
        if !varSec.isPointer
          if varSec.arrayElemCount == 0
            readDef << "( $new" << XCTEPhp::Utils::get_capitalized_first(varSec.name)
            readDef << ")\t{ $this->" << varSec.name << " = $new" << XCTEPhp::Utils::get_capitalized_first(varSec.name) << "; };\n"
          end
        end
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        readDef << "    " << XCTEPhp::Utils::get_comment(varSec)
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        readDef << varSec.formatText
      end
    end

    return(readDef)
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodGet.new)
