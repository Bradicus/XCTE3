##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin deletes a record from the database

require 'x_c_t_e_plugin.rb'
require 'code_name_styling.rb'
require 'plugins_core/lang_csharp/x_c_t_e_csharp.rb'

class XCTECSharp::MethodTsqlDelete < XCTEPlugin

  def initialize
    @name = "method_tsql_delete"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, genFun, cfg, codeBuilder)
    codeBuilder.add("///")
    codeBuilder.add("/// Delete the record for the model with this id")
    codeBuilder.add("///")

    codeBuilder.startClass("public void Delete(SqlTransaction trans, int id)")

    get_body(dataModel, genClass, genFun, cfg, codeBuilder)

    codeBuilder.endClass
  end

  def get_declairation(dataModel, genClass, genFun, cfg, codeBuilder)
    codeBuilder.add("void Delete(SqlTransaction trans, int id);")
  end

  def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
    genClass.addInclude('System.Data.SqlClient', 'SqlTransaction')
  end

  def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(varArray)

    codeBuilder.add('string sql = @"DELETE FROM ' + dataModel.name +
                        ' WHERE ' + XCTECSharp::Utils.instance.getStyledVariableName(varArray[0]) +
                        '=@' + XCTECSharp::Utils.instance.getStyledVariableName(varArray[0]) + '";')

    codeBuilder.add

    codeBuilder.startBlock("try")
    codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))")
    codeBuilder.add('cmd.Parameters.AddWithValue("@' + XCTECSharp::Utils.instance.getStyledVariableName(varArray[0]) +
                        '", id);')
    codeBuilder.endBlock
    codeBuilder.endBlock
    codeBuilder.startBlock("catch(Exception e)")
    codeBuilder.add('throw new Exception("Error deleting ' + dataModel.name + ' with ' +
                        varArray[0].name + ' = "' + ' + id, e);')
    codeBuilder.endBlock
  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlDelete.new)
