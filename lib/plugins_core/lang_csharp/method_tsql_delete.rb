##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin deletes a record from the database

require 'x_c_t_e_plugin'
require 'code_name_styling'

module XCTECSharp
  class MethodTsqlDelete < XCTEPlugin
    def initialize
      @name = 'method_tsql_delete'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add('///')
      bld.add('/// Delete the record for the model with this id')
      bld.add('///')

      identVar = cls.model.getIdentityVar

      if identVar
        bld.startClass('public void Delete(' + Utils.instance.getParamDec(identVar.getParam) +
                       ', SqlConnection conn, SqlTransaction trans = null)')
      end

      get_body(cls, bld, fun)

      bld.endClass
    end

    def get_declairation(cls, bld, _fun)
      identVar = cls.model.getIdentityVar

      return unless identVar

      bld.add('void Delete(' + Utils.instance.getParamDec(identVar.getParam) +
              ', SqlConnection conn, SqlTransaction trans = null);')
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse('System.Data.SqlClient', 'SqlConnection')
    end

    def get_body(cls, bld, _fun)
      conDef = String.new
      varArray = []

      identVar = cls.model.getIdentityVar

      return unless identVar

      identParamName = Utils.instance.get_styled_variable_name(identVar.getParam)

      cls.model.getAllVarsFor(varArray)

      bld.add('string sql = @"DELETE FROM ' + XCTETSql::Utils.instance.get_styled_class_name(cls.getUName) +
              ' WHERE [' + XCTETSql::Utils.instance.get_styled_variable_name(identVar, cls.varPrefix) +
              '] = @' + identParamName + '";')

      bld.add

      bld.startBlock('try')
      bld.startBlock('using(SqlCommand cmd = new SqlCommand(sql, conn))')
      bld.add('cmd.Transaction = trans;')
      bld.add
      bld.add('cmd.Parameters.AddWithValue("@' + identParamName +
              '", ' + identParamName + ');')
      bld.endBlock
      bld.endBlock
      bld.startBlock('catch(Exception e)')
      bld.add('throw new Exception("Error deleting ' + cls.getUName + ' with ' +
              identVar.name + ' = "' + ' + ' + identParamName + ', e);')
      bld.endBlock
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodTsqlDelete.new)
