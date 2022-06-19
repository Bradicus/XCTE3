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
    def get_definition(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("/// <summary>")
      codeBuilder.add("/// Reads set of results using the specified filter parameters")
      codeBuilder.add("/// </summary>")
      codeBuilder.startFunction("public " + get_function_signature(cls, genFun, cfg, codeBuilder))

      get_body(cls, genFun, cfg, codeBuilder)

      codeBuilder.endFunction
    end

    def get_declairation(cls, genFun, cfg, codeBuilder)
      codeBuilder.add(get_function_signature(cls, genFun, cfg, codeBuilder) + ";")
    end

    def get_dependencies(cls, genFun, cfg, codeBuilder)
      cls.addUse("System.Collections.Generic", "IEnumerable")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_function_signature(cls, genFun, cfg, codeBuilder)
      standardClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.model.name)

      paramDec = Array.new
      paramNames = Array.new

      genFun.variableReferences.each() { |param|
        paramDec << XCTECSharp::Utils.instance.getParamDec(param.getParam())
        paramNames << XCTECSharp::Utils.instance.getStyledVariableName(param)
      }

      return "List<" + standardClassName + "> " +
               XCTECSharp::Utils.instance.getStyledFunctionName("retrieve set by " + paramNames.join(" ")) +
               "(SqlConnection conn, " + paramDec.join(", ") + ")"
    end

    def get_body(cls, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      styledClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.model.name)
      codeBuilder.add("List<" + styledClassName + "> resultList = new List<" + styledClassName + ">();")

      codeBuilder.add('string sql = @"SELECT ')

      codeBuilder.indent

      XCTECSharp::Utils.instance.genVarList(varArray, codeBuilder, cls.varPrefix)

      codeBuilder.unindent

      codeBuilder.add("FROM " + XCTETSql::Utils.instance.getStyledClassName(cls.model.name))
      codeBuilder.add("WHERE ")

      codeBuilder.indent

      whereItems = Array.new
      genFun.variableReferences.each() { |param|
        whereCondition =
          "[" + XCTETSql::Utils.instance.getStyledVariableName(param, cls.varPrefix) +
            "] = @" + XCTETSql::Utils.instance.getStyledVariableName(param.getParam())

        whereItems << whereCondition
      }
      codeBuilder.add(whereItems.join(" AND "))
      codeBuilder.sameLine('";')

      codeBuilder.unindent

      codeBuilder.add

      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")

      genFun.variableReferences.each() { |param|
        codeBuilder.add("cmd.Parameters.AddWithValue(" +
                        '"@' + XCTETSql::Utils.instance.getStyledVariableName(param) +
                        '", ' + XCTECSharp::Utils.instance.getStyledVariableName(param.getParam()) + ");")
      }

      codeBuilder.add("SqlDataReader results = cmd.ExecuteReader();")

      codeBuilder.startBlock("while(results.Read())")

      codeBuilder.add("var o = new " + Utils.instance.getStyledClassName(cls.model.name) + "();")
      codeBuilder.add

      Utils.instance.genAssignResults(varArray, cls, codeBuilder)

      codeBuilder.add
      codeBuilder.add("resultList.Add(o);")

      codeBuilder.endBlock
      codeBuilder.endBlock

      codeBuilder.endBlock
      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Error retrieving all items from ' + cls.model.name + '", e);')
      codeBuilder.endBlock(";")

      codeBuilder.add
      codeBuilder.add("return resultList;")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlReadSetBy.new)
