##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_php/x_c_t_e_php.rb'

class XCTEPhp::MethodConstructor < XCTEPlugin
  
  def initialize
    @name = "method_constructor"
    @language = "php"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns definition string for this class's constructor
  def get_definition(codeClass, outCode)
    conDef = String.new
    outCode.indent
                
    outCode.add("/**")
    outCode.add("* Constructor")
    outCode.add("*/")
        
    outCode.add("public function " << codeClass.name << "()")
    outCode.add("{");
        
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE

        outCode.iadd(1, "$this->dataSet['" << var.name << "'] = ")

        if (var.defaultValue != nil)
          defaultVal = var.defaultValue
        elsif var.vtype == "String"
          defaultVal = "";
        else
          defaultVal = "NULL";
        end
        
        if var.vtype == "String"
          outCode.sameLine("\"" << defaultVal << "\";")
        else
          outCode.sameLine(";")
        end

        if var.comment != nil
          outCode.sameLine("\t// " << var.comment)
        end

        outCode.add

      elsif var.elementId == CodeElem::ELEM_FORMAT
        outCode.sameLine(var.formatText)
      end
    end
        
    outCode.add("}");
	outCode.unindent
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodConstructor.new)
