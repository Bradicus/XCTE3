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
    def get_definition(cls, genFun, cfg, bld)
      bld.add("/// <summary>")
      bld.add("/// Reads data set from sql database")
      bld.add("/// </summary>")

      standardClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.getUName())

      bld.startClass("public IEnumerable<" + standardClassName +
                     "> RetrieveAll(SqlConnection conn, SqlTransaction trans = null)")

      get_body(cls, genFun, cfg, bld)

      bld.endClass
    end

    def get_declairation(cls, genFun, cfg, bld)
      bld.add("IEnumerable<" +
              Utils.instance.getStyledClassName(cls.getUName()) +
              "> RetrieveAll(SqlConnection conn, SqlTransaction trans = null);")
    end

    def process_dependencies(cls, genFun, cfg, bld)
      cls.addUse("System.Collections.Generic", "IEnumerable")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_body(cls, genFun, cfg, bld)
      conDef = String.new

      tableName = Utils.instance.getStyledClassName(cls.getUName())
      bld.add("List<" + tableName + "> resultList = new List<" + tableName + ">();")
      bld.add('string sql = @"SELECT ')

      bld.indent

      Utils.instance.genVarList(cls, bld, cls.varPrefix)

      bld.unindent

      bld.add("FROM " + tableName + '";')
      bld.add
      bld.startBlock("try")
      bld.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")
      bld.add("cmd.Transaction = trans;")
      bld.add
      bld.add("SqlDataReader results = cmd.ExecuteReader();")
      bld.startBlock("while(results.Read())")

      bld.add("var o = new " + tableName + "();")

      Utils.instance.genAssignResults(cls, bld)

      bld.endBlock
      bld.endBlock

      bld.endBlock
      bld.startBlock("catch(Exception e)")
      bld.add('throw new Exception("Error retrieving all items from ' + tableName + '", e);')
      bld.endBlock(";")

      bld.add
      bld.add("return resultList;")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlRetrieveAll.new)
