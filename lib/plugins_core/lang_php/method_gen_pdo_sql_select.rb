##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_php/x_c_t_e_php.rb'

class XCTEPhp::MethodGenPDOSQLSelect < XCTEPlugin
  
  def initialize
    @name = "method_gen_pdo_sql_select"
    @language = "php"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns definition string for this class' constructor
  def get_definition(codeClass, cfg, outCode)
    
    outCode.indent
                
    outCode.add("/**")
    outCode.add("* Generates Mysql PDO Select Statement")
    outCode.add("*/")
        
    outCode.add("public function genPDOSelect()")
    outCode.add("{");
    
    outCode.add("    ");
        
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);
    
    outCode.add("    $statement = $dbConn->query(\"SELECT * FROM table\");");

    outCode.add("    $resultData['success'] = true;")
    outCode.add("    $resultData['total'] = $statement->rowCount();")

    outCode.add("    $resultData['" << codeClass.name << "'] = array();")

    outCode.add("    while ($row = $statement->fetchObject()) {")
    outCode.add("        $resultData['" << codeClass.name << "'][] = array(")
        
    outCode.add("            '" << varArray[0].name << "' => $row->" << varArray[0].name)
    
    setVarArray = Array.new(varArray);    
    setVarArray.shift;
    
    for var in setVarArray
      if var.elementId == CodeElem::ELEM_VARIABLE        
        outCode.add("," << "            '" << var.name << "' => $row->" << var.name)
      end
    end
    
    outCode.add("        );")
    outCode.add("    }")
    
	outCode.add("    $serializer = JMS\Serializer\SerializerBuilder::create()->build();");
	outCode.add("    $json = $serializer->serialize($resultData, 'json');");
	outCode.add("    print($json);");
    
    outCode.add("}");
	
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodGenPDOSQLSelect.new)
