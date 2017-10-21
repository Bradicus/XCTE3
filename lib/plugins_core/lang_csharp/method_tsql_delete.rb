##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin deletes a record from the database

require 'x_c_t_e_plugin.rb'
require 'code_name_styling.rb'

module XCTECSharp
  class MethodTsqlDelete < XCTEPlugin

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

      identVar = dataModel.getIdentityVar();
      codeBuilder.startClass('public void Delete(SqlConnection conn, ' + Utils.instance.getParamDec(identVar.getParam()) + ')')

      get_body(dataModel, genClass, genFun, cfg, codeBuilder)

      codeBuilder.endClass
    end

    def get_declairation(dataModel, genClass, genFun, cfg, codeBuilder)
      identVar = dataModel.getIdentityVar();
      codeBuilder.add('void Delete(SqlConnection conn, ' + Utils.instance.getParamDec(identVar.getParam()) + ');')
    end

    def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
      genClass.addUse('System.Data.SqlClient', 'SqlConnection')
    end

    def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new

      identVar = dataModel.getIdentityVar();
      identParamName = Utils.instance.getStyledVariableName(identVar.getParam())

      dataModel.getAllVarsFor(varArray)

      codeBuilder.add('string sql = @"DELETE FROM ' + XCTETSql::Utils.instance.getStyledClassName(dataModel.name) +
                          ' WHERE [' + XCTETSql::Utils.instance.getStyledVariableName(identVar, genClass.varPrefix) +
                                  "] = @" + identParamName	+ '";')

      codeBuilder.add

      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")
      codeBuilder.add('cmd.Parameters.AddWithValue("@' + identParamName +
                          '", ' + identParamName + ');')
      codeBuilder.endBlock
      codeBuilder.endBlock
      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Error deleting ' + dataModel.name + ' with ' +
                  identVar.name + ' = "' + ' + ' + identParamName + ', e);')
      codeBuilder.endBlock
    end

  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlDelete.new)
