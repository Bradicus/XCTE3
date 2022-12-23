require "lang_profile.rb"
require "code_name_styling.rb"

module XCTECSharp
  class MethodTsqlReadSetBy < XCTEPlugin
    def initialize
      @name = "method_tsql_retrieve_set_by"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add("/// <summary>")
      bld.add("/// Reads set of results using the specified filter parameters")
      bld.add("/// </summary>")
      bld.startFunction("public " + get_function_signature(cls, bld, fun))

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_declairation(cls, bld, fun)
      bld.add(get_function_signature(cls, bld, fun) + ";")
    end

    def process_dependencies(cls, bld, fun)
      cls.addUse("System.Collections.Generic", "IEnumerable")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_function_signature(cls, bld, fun)
      standardClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.getUName())

      paramDec = Array.new
      paramNames = Array.new

      fun.variableReferences.each() { |param|
        paramDec << XCTECSharp::Utils.instance.getParamDec(param.getParam())
        paramNames << XCTECSharp::Utils.instance.getStyledVariableName(param)
      }

      return "List<" + standardClassName + "> " +
               XCTECSharp::Utils.instance.getStyledFunctionName("retrieve set by " + paramNames.join(" ")) +
               "(SqlConnection conn, " + paramDec.join(", ") + ")"
    end

    def get_body(cls, bld, fun)
      conDef = String.new

      styledClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.getUName())
      bld.add("List<" + styledClassName + "> resultList = new List<" + styledClassName + ">();")

      bld.add('string sql = @"SELECT ')

      bld.indent

      XCTECSharp::Utils.instance.genVarList(cls, bld, cls.varPrefix)

      bld.unindent

      bld.add("FROM " + XCTETSql::Utils.instance.getStyledClassName(cls.getUName()))
      bld.add("WHERE ")

      bld.indent

      whereItems = Array.new
      fun.variableReferences.each() { |param|
        whereCondition =
          "[" + XCTETSql::Utils.instance.getStyledVariableName(param, cls.varPrefix) +
            "] = @" + XCTETSql::Utils.instance.getStyledVariableName(param.getParam())

        whereItems << whereCondition
      }
      bld.add(whereItems.join(" AND "))
      bld.sameLine('";')

      bld.unindent

      bld.add

      bld.startBlock("try")
      bld.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")

      fun.variableReferences.each() { |param|
        bld.add("cmd.Parameters.AddWithValue(" +
                '"@' + XCTETSql::Utils.instance.getStyledVariableName(param) +
                '", ' + XCTECSharp::Utils.instance.getStyledVariableName(param.getParam()) + ");")
      }

      bld.add("SqlDataReader results = cmd.ExecuteReader();")

      bld.startBlock("while(results.Read())")

      bld.add("var o = new " + Utils.instance.getStyledClassName(cls.getUName()) + "();")
      bld.add

      Utils.instance.genAssignResults(cls, bld)

      bld.add
      bld.add("resultList.Add(o);")

      bld.endBlock
      bld.endBlock

      bld.endBlock
      bld.startBlock("catch(Exception e)")
      bld.add('throw new Exception("Error retrieving all items from ' + cls.getUName() + '", e);')
      bld.endBlock(";")

      bld.add
      bld.add("return resultList;")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlReadSetBy.new)
