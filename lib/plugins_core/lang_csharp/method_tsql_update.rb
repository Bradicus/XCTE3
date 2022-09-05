##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "code_name_styling.rb"

module XCTECSharp
  class MethodTsqlUpdate < XCTEPlugin
    def initialize
      @name = "method_tsql_update"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("///")
      codeBuilder.add("/// Update the record for this model")
      codeBuilder.add("///")

      codeBuilder.startClass("public void Update(" +
                             Utils.instance.getStyledClassName(cls.getUName()) +
                             " o, SqlConnection conn, SqlTransaction trans)")

      get_body(cls, genFun, cfg, codeBuilder)

      codeBuilder.endClass
    end

    def get_declairation(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("void Update(" +
                      Utils.instance.getStyledClassName(cls.getUName()) +
                      " o, SqlConnection conn, SqlTransaction trans);")
    end

    def get_dependencies(cls, genFun, cfg, codeBuilder)
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_body(cls, genFun, cfg, codeBuilder)
      conDef = String.new

      codeBuilder.add('string sql = @"UPDATE ' + XCTETSql::Utils.instance.getStyledClassName(cls.getUName()) + " SET ")

      codeBuilder.indent

      separater = ""
      varArray = Array.new
      cls.model.getNonIdentityVars(varArray)
      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          codeBuilder.sameLine(separater)
          codeBuilder.add("[" + XCTETSql::Utils.instance.getStyledVariableName(var, cls.varPrefix) +
                          "] = @" + Utils.instance.getStyledVariableName(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
        separater = ","
      end

      codeBuilder.unindent

      identVar = cls.model.getIdentityVar()

      if identVar
        codeBuilder.add("WHERE [" + XCTETSql::Utils.instance.getStyledVariableName(identVar, cls.varPrefix) +
                        "] = @" + Utils.instance.getStyledVariableName(identVar) + '";')
      end

      codeBuilder.add

      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")
      codeBuilder.add("cmd.Transaction = trans;")

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      Utils.instance.addParameters(varArray, cls, codeBuilder)

      codeBuilder.add
      codeBuilder.add("cmd.ExecuteScalar();")
      codeBuilder.endBlock
      codeBuilder.endBlock
      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Error updating ' + cls.getUName() + " with " +
                      varArray[0].name + ' = "' + " + o." + CodeNameStyling.stylePascal(varArray[0].name) + ", e);")
      codeBuilder.endBlock(";")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlUpdate.new)
