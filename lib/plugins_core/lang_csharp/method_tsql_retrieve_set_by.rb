require "lang_profile"
require "code_name_styling"

module XCTECSharp
  class MethodTsqlReadSetBy < XCTEPlugin
    def initialize
      @name = "method_tsql_retrieve_set_by"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
          end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      bld.add("/// <summary>")
      bld.add("/// Reads set of results using the specified filter parameters")
      bld.add("/// </summary>")
      bld.start_function("public " + get_function_signature(cls, bld, fun))

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_declairation(cls, bld, fun)
      bld.add(get_function_signature(cls, bld, fun) + ";")
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse("System.Collections.Generic", "IEnumerable")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_function_signature(cls, _bld, fun)
      standard_class_name = XCTECSharp::Utils.instance.style_as_class(cls.get_u_name)

      paramDec = []
      paramNames = []

      fun.parameters.vars.each do |param|
        paramDec << XCTECSharp::Utils.instance.get_param_dec(param.getParam)
        paramNames << XCTECSharp::Utils.instance.get_styled_variable_name(param)
      end

      "List<" + standard_class_name + "> " +
        XCTECSharp::Utils.instance.style_as_function("retrieve set by " + paramNames.join(" ")) +
        "(SqlConnection conn, " + paramDec.join(", ") + ")"
    end

    def get_body(cls, bld, fun)
      conDef = String.new

      styledClassName = XCTECSharp::Utils.instance.style_as_class(cls.get_u_name)
      bld.add("List<" + styledClassName + "> resultList = new List<" + styledClassName + ">();")

      bld.add('string sql = @"SELECT ')

      bld.indent

      XCTECSharp::Utils.instance.genVarList(cls, bld, cls.var_prefix)

      bld.unindent

      bld.add("FROM " + XCTETSql::Utils.instance.style_as_class(cls.get_u_name))
      bld.add("WHERE ")

      bld.indent

      whereItems = []
      fun.parameters.vars.each do |param|
        whereCondition =
          "[" + XCTETSql::Utils.instance.get_styled_variable_name(param, cls.var_prefix) +
          "] = @" + XCTETSql::Utils.instance.get_styled_variable_name(param.getParam)

        whereItems << whereCondition
      end
      bld.add(whereItems.join(" AND "))
      bld.same_line('";')

      bld.unindent

      bld.add

      bld.start_block("try")
      bld.start_block("using(SqlCommand cmd = new SqlCommand(sql, conn))")

      fun.parameters.vars.each do |param|
        bld.add("cmd.Parameters.AddWithValue(" +
                '"@' + XCTETSql::Utils.instance.get_styled_variable_name(param) +
                '", ' + XCTECSharp::Utils.instance.get_styled_variable_name(param.getParam) + ");")
      end

      bld.add("SqlDataReader results = cmd.ExecuteReader();")

      bld.start_block("while(results.Read())")

      bld.add("var o = new " + Utils.instance.style_as_class(cls.get_u_name) + "();")
      bld.add

      Utils.instance.genAssignResults(cls, bld)

      bld.add
      bld.add("resultList.Add(o);")

      bld.end_block
      bld.end_block

      bld.end_block
      bld.start_block("catch(Exception e)")
      bld.add('throw new Exception("Error retrieving all items from ' + cls.get_u_name + '", e);')
      bld.end_block(";")

      bld.add
      bld.add("return resultList;")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodTsqlReadSetBy.new)
