##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'
require 'code_name_styling'
require 'plugins_core/lang_csharp/utils'

module XCTECSharp
  class MethodTsqlCreate < XCTEPlugin
    def initialize
      @name = 'method_tsql_create'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, funCb)
      bld.add('///')
      bld.add('/// Create new record for this model')
      bld.add('/// If you are not using ambient transactions, trans must be defined!')
      bld.add('///')

      bld.start_function('public void Create(' +
                        XCTECSharp::Utils.instance.get_styled_class_name(cls.getUName) +
                        ' o, SqlConnection conn, SqlTransaction trans = null)')

      get_body(cls, bld, funCb)

      bld.endFunction
    end

    def get_declairation(cls, bld, _fun)
      bld.add('void Create(' +
              XCTECSharp::Utils.instance.get_styled_class_name(cls.getUName) +
              ' o, SqlConnection conn, SqlTransaction trans = null);')
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse('System', 'Exception')
      cls.addUse('System.Data.SqlClient', 'SqlConnection')
    end

    def get_body(cls, bld, _fun)
      conDef = String.new
      varArray = []
      cls.model.getNonIdentityVars(varArray)

      bld.add('string sql = @"INSERT INTO ' + XCTETSql::Utils.instance.get_styled_class_name(cls.getUName) + '(')

      bld.indent

      Utils.instance.genVarList(cls, bld, cls.varPrefix)

      bld.unindent
      bld.add(') VALUES (')
      bld.indent

      Utils.instance.genParamList(cls, bld)

      bld.unindent
      bld.add(')";')

      bld.add

      bld.start_block('try')
      bld.start_block('using(SqlCommand cmd = new SqlCommand(sql, conn))')
      bld.add('cmd.Transaction = trans;')

      Utils.instance.addNonIdentityParams(cls, bld)

      bld.add

      identVar = cls.model.getIdentityVar

      if !identVar.nil?
        bld.add('var newId = cmd.ExecuteScalar();')
        bld.add('o.' + Utils.instance.get_styled_variable_name(identVar) +
                ' = Convert.To' + identVar.vtype + '(newId);')
      end

      bld.end_block
      bld.end_block
      bld.start_block('catch(Exception e)')
      bld.add('throw new Exception("Error inserting ' +
              XCTETSql::Utils.instance.get_styled_class_name(cls.getUName) + ' into database", e);')
      bld.end_block(';')
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodTsqlCreate.new)
