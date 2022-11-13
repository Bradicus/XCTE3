##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"

module XCTECSharp
  class MethodTsqlRetrieveAll < XCTEPlugin
    def initialize
      @name = "method_tsql_retrieve_all"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("/// <summary>")
      codeBuilder.add("/// Reads data set from sql database")
      codeBuilder.add("/// </summary>")

      standardClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.getUName())

      codeBuilder.startClass("public IEnumerable<" + standardClassName +
                             "> RetrieveAll(SqlConnection conn, SqlTransaction trans = null)")

      get_body(cls, genFun, cfg, codeBuilder)

      codeBuilder.endClass
    end

    def get_declairation(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("IEnumerable<" +
                      Utils.instance.getStyledClassName(cls.getUName()) +
                      "> RetrieveAll(SqlConnection conn, SqlTransaction trans = null);")
    end

    def process_dependencies(cls, genFun, cfg, codeBuilder)
      cls.addUse("System.Collections.Generic", "IEnumerable")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_body(cls, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      tableName = Utils.instance.getStyledClassName(cls.getUName())
      codeBuilder.add("List<" + tableName + "> resultList = new List<" + tableName + ">();")
      codeBuilder.add('string sql = @"SELECT ')

      codeBuilder.indent

      Utils.instance.genVarList(varArray, codeBuilder, cls.varPrefix)

      codeBuilder.unindent

      codeBuilder.add("FROM " + tableName + '";')
      codeBuilder.add
      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")
      codeBuilder.add("cmd.Transaction = trans;")
      codeBuilder.add
      codeBuilder.add("SqlDataReader results = cmd.ExecuteReader();")
      codeBuilder.startBlock("while(results.Read())")

      codeBuilder.add("var o = new " + tableName + "();")

      Utils.instance.genAssignResults(cls, codeBuilder)

      codeBuilder.endBlock
      codeBuilder.endBlock

      codeBuilder.endBlock
      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Error retrieving all items from ' + tableName + '", e);')
      codeBuilder.endBlock(";")

      codeBuilder.add
      codeBuilder.add("return resultList;")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlRetrieveAll.new)
