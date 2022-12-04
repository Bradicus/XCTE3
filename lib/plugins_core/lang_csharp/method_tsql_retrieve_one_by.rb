require "lang_profile.rb"
require "code_name_styling.rb"

module XCTECSharp
  class MethodTsqlReadOneBy < XCTEPlugin
    def initialize
      @name = "method_tsql_retrieve_one_by"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add("/// <summary>")
      bld.add("/// Reads one result using the specified filter parameters")
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
      standardClassName = Utils.instance.getStyledClassName(cls.getUName())

      paramDec = Array.new
      paramNames = Array.new

      fun.variableReferences.each() { |param|
        paramDec << Utils.instance.getParamDec(param.getParam())
        paramNames << Utils.instance.getStyledVariableName(param)
      }

      return standardClassName + " " + XCTECSharp::Utils.instance.getStyledFunctionName("retrieve one by " + paramNames.join(" ")) +
               "(" + paramDec.join(", ") + ", SqlConnection conn, SqlTransaction trans = null)"
    end

    def get_body(cls, bld, fun)
      conDef = String.new

      styledClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.getUName())

      bld.add("var o = new " + XCTECSharp::Utils.instance.getStyledClassName(cls.getUName()) + "();")

      bld.add('string sql = @"SELECT TOP 1 ')

      bld.indent

      bld.unindent

      bld.add("FROM " + cls.getUName())
      bld.add("WHERE ")

      bld.indent

      whereItems = Array.new
      fun.variableReferences.each() { |param|
        whereCondition = "[" +
                         XCTETSql::Utils.instance.getStyledVariableName(param, cls.varPrefix) +
                         "] = @" + Utils.instance.getStyledVariableName(param.getParam())

        whereItems << whereCondition
      }
      bld.add(whereItems.join(" AND "))
      bld.sameLine('";')

      bld.unindent

      bld.add

      bld.startBlock("try")
      bld.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")
      bld.add("cmd.Transaction = trans;")
      bld.add

      fun.variableReferences.each() { |param|
        bld.add("cmd.Parameters.AddWithValue(" +
                '"@' + XCTETSql::Utils.instance.getStyledVariableName(param) +
                '", ' + XCTECSharp::Utils.instance.getStyledVariableName(param.getParam()) + ");")
      }

      bld.add("SqlDataReader results = cmd.ExecuteReader();")

      bld.startBlock("while(results.Read())")

      Utils.instance.genAssignResults(cls, bld)

      bld.endBlock
      bld.endBlock

      bld.endBlock
      bld.startBlock("catch(Exception e)")
      bld.add('throw new Exception("Error retrieving one item from ' + cls.getUName() + '", e);')
      bld.endBlock(";")

      bld.add
      bld.add("return o;")
    end

    # process variable group
    def process_var_group_sql(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if Utils.instance.isPrimitive(var)
            return
            "[" +
            XCTETSql::Utils.instance.getStyledVariableName(var, cls.varPrefix) +
            "] = @" + Utils.instance.getStyledVariableName(var.getParam())
          end
        end
        for group in vGroup.groups
          process_var_group_sql(cls, bld, group)
        end
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlReadOneBy.new)
