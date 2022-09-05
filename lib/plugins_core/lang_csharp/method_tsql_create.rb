##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "code_name_styling.rb"
require "plugins_core/lang_csharp/utils.rb"

module XCTECSharp
  class MethodTsqlCreate < XCTEPlugin
    def initialize
      @name = "method_tsql_create"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("///")
      codeBuilder.add("/// Create new record for this model")
      codeBuilder.add("/// If you are not using ambient transactions, trans must be defined!")
      codeBuilder.add("///")

      codeBuilder.startFunction("public void Create(" +
                                XCTECSharp::Utils.instance.getStyledClassName(cls.getUName()) +
                                " o, SqlConnection conn, SqlTransaction trans = null)")

      get_body(cls, genFun, cfg, codeBuilder)

      codeBuilder.endFunction
    end

    def get_declairation(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("void Create(" +
                      XCTECSharp::Utils.instance.getStyledClassName(cls.getUName()) +
                      " o, SqlConnection conn, SqlTransaction trans = null);")
    end

    def get_dependencies(cls, genFun, cfg, codeBuilder)
      cls.addUse("System", "Exception")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_body(cls, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new
      cls.model.getNonIdentityVars(varArray)

      codeBuilder.add('string sql = @"INSERT INTO ' + XCTETSql::Utils.instance.getStyledClassName(cls.getUName()) + "(")

      codeBuilder.indent

      Utils.instance.genVarList(varArray, codeBuilder, cls.varPrefix)

      codeBuilder.unindent
      codeBuilder.add(") VALUES (")
      codeBuilder.indent

      Utils.instance.genParamList(varArray, codeBuilder)

      codeBuilder.unindent
      codeBuilder.add(')";')

      codeBuilder.add

      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")
      codeBuilder.add("cmd.Transaction = trans;")

      Utils.instance.addNonIdentityParams(cls, codeBuilder)

      codeBuilder.add

      identVar = cls.model.getIdentityVar()

      if identVar != nil
        codeBuilder.add("var newId = cmd.ExecuteScalar();")
        codeBuilder.add("o." + Utils.instance.getStyledVariableName(identVar) +
                        " = Convert.To" + identVar.vtype + "(newId);")
      end

      codeBuilder.endBlock
      codeBuilder.endBlock
      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Error inserting ' +
                      XCTETSql::Utils.instance.getStyledClassName(cls.getUName()) + ' into database", e);')
      codeBuilder.endBlock(";")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlCreate.new)
