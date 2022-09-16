##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin generates a create statement for a database based 
# on this class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_sql/x_c_t_e_sql.rb'

module XCTESql
  class StatementCreate < XCTEPlugin
      
    def initialize
      @name = "statement_create"
      @language = "sql"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_lines(codeClass, cfg)
      sqlCDef = Array.new
      indent = ""

      codeLine = indent + "CREATE TABLE `" + codeClass.name + "List` ("
      sqlCDef << codeLine
      sqlCDef << indent << "`id` INT"

      varArray = Array.new
      codeClass.getAllVarsFor(varArray);

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          codeLine = ", "

          codeLine << XCTESql::Utils::getVarDec(var)

          if var.defaultValue != nil
            codeLine << " default '" << var.defaultValue << "'"
          end

          sqlCDef << codeLine
        end
      end

      sqlCDef << indent << ", PRIMARY KEY (`id`)"

      sqlCDef << indent << " ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"

      return(sqlCDef);  
    end
  end
end
