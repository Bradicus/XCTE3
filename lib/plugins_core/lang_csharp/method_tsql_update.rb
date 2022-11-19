##

#
# Copyright XCTE Contributors
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
    def get_definition(cls, genFun, cfg, bld)
      bld.add("///")
      bld.add("/// Update the record for this model")
      bld.add("///")

      bld.startClass("public void Update(" +
                     Utils.instance.getStyledClassName(cls.getUName()) +
                     " o, SqlConnection conn, SqlTransaction trans)")

      get_body(cls, genFun, cfg, bld)

      bld.endClass
    end

    def get_declairation(cls, genFun, cfg, bld)
      bld.add("void Update(" +
              Utils.instance.getStyledClassName(cls.getUName()) +
              " o, SqlConnection conn, SqlTransaction trans);")
    end

    def process_dependencies(cls, genFun, cfg, bld)
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_body(cls, genFun, cfg, bld)
      conDef = String.new

      bld.add('string sql = @"UPDATE ' + XCTETSql::Utils.instance.getStyledClassName(cls.getUName()) + " SET ")

      bld.indent

      separater = ""
      varArray = Array.new
      cls.model.getNonIdentityVars(varArray)
      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.sameLine(separater)
          bld.add("[" + XCTETSql::Utils.instance.getStyledVariableName(var, cls.varPrefix) +
                  "] = @" + Utils.instance.getStyledVariableName(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
        separater = ","
      end

      bld.unindent

      identVar = cls.model.getIdentityVar()

      if identVar
        bld.add("WHERE [" + XCTETSql::Utils.instance.getStyledVariableName(identVar, cls.varPrefix) +
                "] = @" + Utils.instance.getStyledVariableName(identVar) + '";')
      else
        bld.add("WHERE" + '";')
      end

      bld.add

      bld.startBlock("try")
      bld.startBlock("using(SqlCommand cmd = new SqlCommand(sql, conn))")
      bld.add("cmd.Transaction = trans;")

      Utils.instance.addParameters(varArray, cls, bld)

      bld.add
      bld.add("cmd.ExecuteScalar();")
      bld.endBlock
      bld.endBlock
      bld.startBlock("catch(Exception e)")
      bld.add('throw new Exception("Error updating ' + cls.getUName() + " with " +
              varArray[0].name + ' = "' + " + o." + CodeNameStyling.stylePascal(varArray[0].name) + ", e);")
      bld.endBlock(";")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlUpdate.new)
