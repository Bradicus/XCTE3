##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin generates a create statement for a database based 
# on this class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_sql/x_c_t_e_sql.rb'

module XCTETSql
  class StatementCreate < XCTEPlugin
      
    def initialize
      @name = "statement_create"
      @language = "tsql"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_lines(codeClass, cfg)
      sqlCDef = Array.new
      first = true

      codeLine = "CREATE TABLE `" + codeClass.name + "` ("
      sqlCDef << codeLine
      
      varArray = Array.new
      codeClass.getAllVarsFor(cfg, varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          codeLine = ", "

          codeLine << XCTETSql::Utils::getVarDec(var)

          if var.defaultValue != nil
            codeLine << " default '" << var.defaultValue << "'"
          end

          sqlCDef << codeLine
        end
      end

      sqlCDef << indent << ", PRIMARY KEY (`id`)"

      sqlCDef << indent << " ) "

      return(sqlCDef);  
    end
  end
end
