##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_csharp/x_c_t_e_csharp.rb'

class XCTECSharp::MethodTsqlRetrieveAll < XCTEPlugin
  
  def initialize
    @name = "method_tsql_retrieve_all"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end
  
  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, cfg, codeBuilder)
    codeBuilder.add("/**")
    codeBuilder.add("* Reads data set from sql database")
    codeBuilder.add("*/")

    codeBuilder.startClass("IEnumerable<" + dataModel.name + "> RetrieveAll(SqlTransaction trans)")

    get_body(dataModel, genClass, cfg, codeBuilder)
        
    codeBuilder.endClass
  end

  def get_declairation(dataModel, genClass, cfg, codeBuilder)
    codeBuilder.add("IEnumerable<" + dataModel.name + "> RetrieveAll(SqlTransaction trans);")
  end

  def get_dependencies(dataModel, genClass, cfg, codeBuilder)
    genClass.addInclude('System.Collections.Generic', 'IEnumerable')
    genClass.addInclude('System.Data.SqlClient', 'SqlTransaction')
  end

  def get_body(dataModel, genClass, cfg, codeBuilder)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(cfg, varArray)

    codeBuilder.add('string sql = @"SELECT ')

    codeBuilder.indent

    first = true;
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !first
          codeBuilder.sameLine(',')
        end
        first = false

        codeBuilder.add(CodeNameStyling.stylePascal(var.name))
      else
        if var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
      end
    end

    codeBuilder.unindent

    codeBuilder.add('FROM ' + dataModel.name + '";')


    codeBuilder.add

    codeBuilder.startBlock("try")
    codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))")

    codeBuilder.add

    codeBuilder.add('SqlDataReader results = cmd.ExecuteReader();')

    codeBuilder.startBlock('while(results.Read())')
    codeBuilder.add("o." + XCTECSharp::Utils::getStyledName(varArray[0]) + ' = Convert.ToInt32(newId);')

    codeBuilder.endBlock
    codeBuilder.endBlock

    codeBuilder.endBlock
    codeBuilder.startBlock("catch(Exception e)")
    codeBuilder.add('throw new Exception("Error retrieving all items from ' + dataModel.name + '");')
    codeBuilder.endBlock(';')
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlRetrieveAll.new)
