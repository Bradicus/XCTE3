##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_php/x_c_t_e_php.rb'

class XCTEPhp::MethodGenPDOSQLUpdate < XCTEPlugin
  
  def initialize
    @name = "method_gen_pdo_sql_update"
    @language = "php"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns definition string for this class' constructor
  def get_definition(codeClass, cfg, outCode)
    
    outCode.indent
                
    outCode.add("/**")
    outCode.add("* Generates Mysql PDO Statement")
    outCode.add("*/")
        
    outCode.add("public function genPDOStatement()")
    outCode.add("{");
    
    outCode.add("    ");
        
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);
    
    outCode.add("    $sql = 'UPDATE company SET';");
    outCode.add("    $sql .= ' " << varArray[0].name << "=:" << varArray[0].name << "';");
        
    setVarArray = Array.new(varArray);    
    setVarArray.shift;
    
    for var in setVarArray
      if var.elementId == CodeElem::ELEM_VARIABLE        
        outCode.add("    $sql .= ', " << var.name << "=:" << var.name << "';");
      end
    end
    
    outCode.add("    $sql .= \" WHERE id=''\";");
    
    outCode.add("    $statement = $dbConn->prepare($sql);");
    
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE        
        outCode.add("    $statement->bindParam(':" << var.name << "', $pData->" << var.name << ");");
      end
    end
    
    outCode.add("");
    outCode.add("    $result = $statement->execute();");
    
    outCode.add("}");

    return(outCode);
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodGenPDOSQLUpdate.new)
