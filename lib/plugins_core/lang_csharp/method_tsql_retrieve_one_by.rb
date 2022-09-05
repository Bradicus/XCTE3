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
    def get_definition(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("/// <summary>")
      codeBuilder.add("/// Reads one result using the specified filter parameters")
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
      standardClassName = Utils.instance.getStyledClassName(cls.getUName())

      paramDec = Array.new
      paramNames = Array.new

      genFun.variableReferences.each() { |param|
        paramDec << Utils.instance.getParamDec(param.getParam())
        paramNames << Utils.instance.getStyledVariableName(param)
      }

      return standardClassName + " " + XCTECSharp::Utils.instance.getStyledFunctionName("retrieve one by " + paramNames.join(" ")) +
               "(" + paramDec.join(", ") + ", SqlConnection conn, SqlTransaction trans = null)"
    end

    def get_body(cls, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      styledClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.getUName())

      codeBuilder.add("var o = new " + XCTECSharp::Utils.instance.getStyledClassName(cls.getUName()) + "();")

      codeBuilder.add('string sql = @"SELECT TOP 1 ')

      codeBuilder.indent

      XCTECSharp::Utils.instance.genVarList(varArray, codeBuilder, cls.varPrefix)

      codeBuilder.unindent

      codeBuilder.add("FROM " + cls.getUName())
      codeBuilder.add("WHERE ")

      codeBuilder.indent

      whereItems = Array.new
      genFun.variableReferences.each() { |param|
        whereCondition = "[" +
                         XCTETSql::Utils.instance.getStyledVariableName(param, cls.varPrefix) +
                         "] = @" + Utils.instance.getStyledVariableName(param.getParam())

        whereItems << whereCondition
      }
      codeBuilder.add(whereItems.join(" AND "))
      codeBuilder.sameLine('";')

      codeBuilder.unindent

      codeBuilder.add

      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")
      codeBuilder.add("cmd.Transaction = trans;")
      codeBuilder.add

      genFun.variableReferences.each() { |param|
        codeBuilder.add("cmd.Parameters.AddWithValue(" +
                        '"@' + XCTETSql::Utils.instance.getStyledVariableName(param) +
                        '", ' + XCTECSharp::Utils.instance.getStyledVariableName(param.getParam()) + ");")
      }

      codeBuilder.add("SqlDataReader results = cmd.ExecuteReader();")

      codeBuilder.startBlock("while(results.Read())")

      Utils.instance.genAssignResults(varArray, cls, codeBuilder)

      codeBuilder.endBlock
      codeBuilder.endBlock

      codeBuilder.endBlock
      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Error retrieving one item from ' + cls.getUName() + '", e);')
      codeBuilder.endBlock(";")

      codeBuilder.add
      codeBuilder.add("return o;")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlReadOneBy.new)
