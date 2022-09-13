##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin deletes a record from the database

require "x_c_t_e_plugin.rb"
require "code_name_styling.rb"

module XCTECSharp
  class MethodTsqlDelete < XCTEPlugin
    def initialize
      @name = "method_tsql_delete"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("///")
      codeBuilder.add("/// Delete the record for the model with this id")
      codeBuilder.add("///")

      identVar = cls.model.getIdentityVar()

      if (identVar)
        codeBuilder.startClass("public void Delete(" + Utils.instance.getParamDec(identVar.getParam()) +
                               ", SqlConnection conn, SqlTransaction trans = null)")
      end

      get_body(cls, genFun, cfg, codeBuilder)

      codeBuilder.endClass
    end

    def get_declairation(cls, genFun, cfg, codeBuilder)
      identVar = cls.model.getIdentityVar()

      if (identVar)
        codeBuilder.add("void Delete(" + Utils.instance.getParamDec(identVar.getParam()) +
                        ", SqlConnection conn, SqlTransaction trans = null);")
      end
    end

    def process_dependencies(cls, genFun, cfg, codeBuilder)
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_body(cls, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new

      identVar = cls.model.getIdentityVar()

      if (identVar)
        identParamName = Utils.instance.getStyledVariableName(identVar.getParam())

        cls.model.getAllVarsFor(varArray)

        codeBuilder.add('string sql = @"DELETE FROM ' + XCTETSql::Utils.instance.getStyledClassName(cls.getUName()) +
                        " WHERE [" + XCTETSql::Utils.instance.getStyledVariableName(identVar, cls.varPrefix) +
                        "] = @" + identParamName + '";')

        codeBuilder.add

        codeBuilder.startBlock("try")
        codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")
        codeBuilder.add("cmd.Transaction = trans;")
        codeBuilder.add
        codeBuilder.add('cmd.Parameters.AddWithValue("@' + identParamName +
                        '", ' + identParamName + ");")
        codeBuilder.endBlock
        codeBuilder.endBlock
        codeBuilder.startBlock("catch(Exception e)")
        codeBuilder.add('throw new Exception("Error deleting ' + cls.getUName() + " with " +
                        identVar.name + ' = "' + " + " + identParamName + ", e);")
        codeBuilder.endBlock
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlDelete.new)
