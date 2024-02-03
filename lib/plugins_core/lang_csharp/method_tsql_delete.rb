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
    def render_function(cls, bld, fun)
      bld.add('///')
      bld.add('/// Delete the record for the model with this id')
      bld.add('///')

      ident_var = cls.model.getIdentityVar

      if ident_var
        bld.start_class('public void Delete(' + Utils.instance.get_param_dec(ident_var.getParam) +
                       ', SqlConnection conn, SqlTransaction trans = null)')
      end

      get_body(cls, bld, fun)

      bld.end_class
    end

    def get_declairation(cls, bld, _fun)
      ident_var = cls.model.getIdentityVar

      return unless ident_var

      bld.add('void Delete(' + Utils.instance.get_param_dec(ident_var.getParam) +
              ', SqlConnection conn, SqlTransaction trans = null);')
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse('System.Data.SqlClient', 'SqlConnection')
    end

    def get_body(cls, bld, _fun)
      conDef = String.new
      varArray = []

      ident_var = cls.model.getIdentityVar

      if ident_var
        identParamName = Utils.instance.get_styled_variable_name(ident_var.getParam)

        bld.add('string sql = @"DELETE FROM ' + XCTETSql::Utils.instance.get_styled_class_name(cls.getUName) +
                ' WHERE [' + XCTETSql::Utils.instance.get_styled_variable_name(ident_var, cls.var_prefix) +
                '] = @' + identParamName + '";')

        bld.add

        bld.start_block('try')
        bld.start_block('using(SqlCommand cmd = new SqlCommand(sql, conn))')
        bld.add('cmd.Transaction = trans;')
        bld.add
        bld.add('cmd.Parameters.AddWithValue("@' + identParamName +
                '", ' + identParamName + ');')
        bld.end_block
        bld.end_block
        bld.start_block('catch(Exception e)')
        bld.add('throw new Exception("Error deleting ' + cls.getUName + ' with ' +
                ident_var.name + ' = "' + ' + ' + identParamName + ', e);')
        bld.end_block
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodTsqlDelete.new)
