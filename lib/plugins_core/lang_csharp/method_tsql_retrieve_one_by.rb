require 'lang_profile'
require 'code_name_styling'

module XCTECSharp
  class MethodTsqlReadOneBy < XCTEPlugin
    def initialize
      @name = 'method_tsql_retrieve_one_by'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_METHOD
      @author = 'Brad Ottoson'
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add('/// <summary>')
      bld.add('/// Reads one result using the specified filter parameters')
      bld.add('/// </summary>')
      bld.start_function('public ' + get_function_signature(cls, bld, fun))

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_declairation(cls, bld, fun)
      bld.add(get_function_signature(cls, bld, fun) + ';')
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse('System.Collections.Generic', 'IEnumerable')
      cls.addUse('System.Data.SqlClient', 'SqlConnection')
    end

    def get_function_signature(cls, _bld, fun)
      standard_class_name = Utils.instance.get_styled_class_name(cls.getUName)

      paramDec = []
      paramNames = []

      fun.variableReferences.each do |param|
        paramDec << Utils.instance.getParamDec(param.getParam)
        paramNames << Utils.instance.get_styled_variable_name(param)
      end

      standard_class_name + ' ' + XCTECSharp::Utils.instance.get_styled_function_name('retrieve one by ' + paramNames.join(' ')) +
        '(' + paramDec.join(', ') + ', SqlConnection conn, SqlTransaction trans = null)'
    end

    def get_body(cls, bld, fun)
      conDef = String.new

      styledClassName = XCTECSharp::Utils.instance.get_styled_class_name(cls.getUName)

      bld.add('var o = new ' + XCTECSharp::Utils.instance.get_styled_class_name(cls.getUName) + '();')

      bld.add('string sql = @"SELECT TOP 1 ')

      bld.indent

      bld.unindent

      bld.add('FROM ' + cls.getUName)
      bld.add('WHERE ')

      bld.indent

      whereItems = []
      fun.variableReferences.each do |param|
        whereCondition = '[' +
                         XCTETSql::Utils.instance.get_styled_variable_name(param, cls.varPrefix) +
                         '] = @' + Utils.instance.get_styled_variable_name(param.getParam)

        whereItems << whereCondition
      end
      bld.add(whereItems.join(' AND '))
      bld.same_line('";')

      bld.unindent

      bld.add

      bld.start_block('try')
      bld.start_block('using(SqlCommand cmd = new SqlCommand(sql, conn))')
      bld.add('cmd.Transaction = trans;')
      bld.add

      fun.variableReferences.each do |param|
        bld.add('cmd.Parameters.AddWithValue(' +
                '"@' + XCTETSql::Utils.instance.get_styled_variable_name(param) +
                '", ' + XCTECSharp::Utils.instance.get_styled_variable_name(param.getParam) + ');')
      end

      bld.add('SqlDataReader results = cmd.ExecuteReader();')

      bld.start_block('while(results.Read())')

      Utils.instance.genAssignResults(cls, bld)

      bld.end_block
      bld.end_block

      bld.end_block
      bld.start_block('catch(Exception e)')
      bld.add('throw new Exception("Error retrieving one item from ' + cls.getUName + '", e);')
      bld.end_block(';')

      bld.add
      bld.add('return o;')
    end

    # process variable group
    def process_var_group_sql(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE && Utils.instance.is_primitive(var)
          return
          '[' +
            XCTETSql::Utils.instance.get_styled_variable_name(var, cls.varPrefix) +
            '] = @' + Utils.instance.get_styled_variable_name(var.getParam)
        end
        for group in vGroup.varGroups
          process_var_group_sql(cls, bld, group)
        end
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodTsqlReadOneBy.new)
