# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_php/x_c_t_e_php.rb' 

module XCTEPhp
  class MethodDataListLoadCell < XCTEPlugin

    def initialize
      @name = "method_data_list_load_cell"
      @language = "php"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_definition(codeClass, cfg, outCode)
      outCode.indent

      outCode.add("/**")
      outCode.add("* Loads data into a cell in this data set")
      outCode.add("*/")

      outCode.add("public function loadCell($cellString, $errorList, $curRowIndex, $curCellIndex)")
      outCode.add("{");
      
      outCode.iadd(1, "if (isset($cellString) && strlen(trim($cellString)) > 0)");
      outCode.iadd(1, "{");
      outCode.iadd(2,     "switch($curCellIndex)");
      outCode.iadd(2,     "{");
      
      varNum = 0;

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
                                
            if XCTEPhp::Utils::isPrimitive(var)
              outCode.iadd(3, "case " << varNum.to_s << ": $this->dataSet['" << var.name << "'] = ")
              outCode.iadd(3, "$cellString; break;")   
            else
              outCode.iadd(3, "case " << varNum.to_s << ": $this->dataSet['" << var.name << "'] = ")
              outCode.sameLine("new " << var.vtype << "($cellString); break;")          
            end         
          
            varNum = varNum + 1;
        end
      end
      
      outCode.iadd(3, "default: break;");
      
      outCode.iadd(2, "}");
      outCode.iadd(1, "}");
      
      outCode.add("}");
      outCode.unindent
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodDataListLoadCell.new)
