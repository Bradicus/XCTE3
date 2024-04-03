##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'
require 'code_name_styling'

module XCTECSharp
  class MethodTsqlUpdate < XCTEPlugin
    def initialize
      @name = 'method_tsql_update'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_METHOD
      @author = 'Brad Ottoson'
    end

    # Returns definition string for this class's constructor
    def render_function(cls, bld, fun)
      bld.add('///')
      bld.add('/// Update the record for this model')
      bld.add('///')

      bld.start_class('public void Update(' +
                     Utils.instance.style_as_class(cls.get_u_name) +
                     ' o, SqlConnection conn, SqlTransaction trans)')

      get_body(cls, bld, fun)

      bld.end_class
    end

    def get_declairation(cls, bld, _fun)
      bld.add('void Update(' +
              Utils.instance.style_as_class(cls.get_u_name) +
              ' o, SqlConnection conn, SqlTransaction trans);')
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse('System.Data.SqlClient', 'SqlConnection')
    end

    def get_body(cls, bld, _fun)
      conDef = String.new

      bld.add('string sql = @"UPDATE ' + XCTETSql::Utils.instance.style_as_class(cls.get_u_name) + ' SET ')

      bld.indent

      separater = ''
      varArray = []
      cls.model.getNonIdentityVars(varArray)
      for var in varArray
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          bld.same_line(separater)
          bld.add('[' + XCTETSql::Utils.instance.get_styled_variable_name(var, cls.var_prefix) +
                  '] = @' + Utils.instance.get_styled_variable_name(var))
        elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
          bld.add(var.formatText)
        end
        separater = ','
      end

      bld.unindent

      ident_var = cls.model.getIdentityVar

      if ident_var
        bld.add('WHERE [' + XCTETSql::Utils.instance.get_styled_variable_name(ident_var, cls.var_prefix) +
                '] = @' + Utils.instance.get_styled_variable_name(ident_var) + '";')
      else
        bld.add('WHERE' + '";')
      end

      bld.add

      bld.start_block('try')
      bld.start_block('using(SqlCommand cmd = new SqlCommand(sql, conn))')
      bld.add('cmd.Transaction = trans;')

      Utils.instance.addParameters(varArray, cls, bld)

      bld.add
      bld.add('cmd.ExecuteScalar();')
      bld.end_block
      bld.end_block
      bld.start_block('catch(Exception e)')
      bld.add('throw new Exception("Error updating ' + cls.get_u_name + ' with ' +
              varArray[0].name + ' = "' + ' + o.' + CodeNameStyling.stylePascal(varArray[0].name) + ', e);')
      bld.end_block(';')
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodTsqlUpdate.new)
