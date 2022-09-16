##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a class that returns a mysql string for creating 
# a database table based on this class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_php/x_c_t_e_php.rb'
require 'plugins_core/lang_sql/statement_create.rb'

module XCTEPhp
  class MethodGetMysqlCreateString < XCTEPlugin
    
    def initialize
      @name = "method_get_mysql_create"
      @language = "php"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end
    
    # Returns definition string for this class's mysql create 
    # statement generator
    def get_definition(codeClass, cfg, outCode)
      outCode.indent

      outCode.add("/**")
      outCode.add("* Returns a mysql create statement based on this")
      outCode.add("* classes data.")
      outCode.add("*/")

      outCode.add("getMySQLCreate()")
      outCode.add("{");
      
      sqlCreateGen = XCTESql::StatementCreate.new
      outCode.iadd("createString = \"\";")

      sqlLines = sqlCreateGen.get_lines(codeClass, cfg)
      
      for cLine in sqlLines
        outCode.iadd("createString .= ")
        outCode.iadd(' "' << cLine << '";')
      end
      
      outCode.iadd("return(createString);")
      outCode.add("}")

      return(conDef)
    end
    
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodGetMysqlCreateString.new)
