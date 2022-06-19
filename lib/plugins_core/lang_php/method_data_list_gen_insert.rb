##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "data list gen insert" classes.
# This code creates a mysql inster statement for class data

module XCTEPhp
  class MethodDataListGenInsert < XCTEPlugin

    def initialize
      @name = "method_data_list_gen_insert"
      @language = "php"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_definition(codeClass, cfg, outCode)
      outCode.indent

      outCode.add("/**")
      outCode.add("* Creates an insert statement for this classes data")
      outCode.add("*/")

      outCode.add("public function genInsert($cellString, $curCellIndex)")
      outCode.add("{");
      
      outCode.add("    $inserts = ")
      outCode.add('"INSERT INTO ' << codeClass.name << 'List VALUES (";')
 #     outCode.add("'.\\n\";")
            
      varNum = 0

#      for var in codeClass.variableSection
#        if var.elementId == CodeElem::ELEM_VARIABLE
#                                
#            if XCTEPhp::Utils::isPrimitive(var)
#              conDef << "            case " << varNum.to_s << ": $this->dataSet['" << var.name << "'] = "
#              conDef << "$cellString; break;")   
#            else
#              conDef << "            case " << varNum.to_s << ": $this->dataSet['" << var.name << "'] = "
#              conDef << "new " << var.vtype << "($cellString); break;")          
#            end         
#          
#            varNum = varNum + 1;
#        end
#      end
      
      
      outCode.add("}");

      return(conDef);
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodDataListGenInsert.new)
