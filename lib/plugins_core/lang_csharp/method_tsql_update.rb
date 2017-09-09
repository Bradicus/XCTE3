##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin.rb'
require 'code_name_styling.rb'

module XCTECSharp
  class MethodTsqlUpdate < XCTEPlugin

    def initialize
      @name = "method_tsql_update"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_definition(dataModel, genClass, genFun, cfg, codeBuilder)
      codeBuilder.add("///")
      codeBuilder.add("/// Update the record for this model")
      codeBuilder.add("///")

      codeBuilder.startClass("public void Update(SqlTransaction trans, " + Utils.instance.getStyledClassName(dataModel.name) + " o)")

      get_body(dataModel, genClass, genFun, cfg, codeBuilder)

      codeBuilder.endClass
    end

    def get_declairation(dataModel, genClass, genFun, cfg, codeBuilder)
      codeBuilder.add("void Update(SqlTransaction trans, " + Utils.instance.getStyledClassName(dataModel.name) + " o);")
    end

    def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
      genClass.addUse('System.Data.SqlClient', 'SqlTransaction')
    end
    
    def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
      conDef = String.new

      codeBuilder.add('string sql = @"UPDATE ' + XCTETSql::Utils.instance.getStyledClassName(dataModel.name) + ' SET ')

      codeBuilder.indent

      separater = ''
      varArray = Array.new
      dataModel.getNonIdentityVars(varArray)
      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          codeBuilder.sameLine(separater)        
          codeBuilder.add('[' + XCTETSql::Utils.instance.getStyledVariableName(var, genClass.varPrefix) +
              "] = @" + Utils.instance.getStyledVariableName(var))              
        elsif var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
        separater = ','
      end

      codeBuilder.unindent
      
      identVar = dataModel.getIdentityVar();
      codeBuilder.add('WHERE [' + XCTETSql::Utils.instance.getStyledVariableName(identVar, genClass.varPrefix) +
              "] = @" + Utils.instance.getStyledVariableName(identVar)	+ '";')

      codeBuilder.add

      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))")

      varArray = Array.new
      dataModel.getAllVarsFor(varArray)

      Utils.instance.addParameters(varArray, genClass, codeBuilder)
      
      codeBuilder.add
      codeBuilder.add('cmd.ExecuteScalar();')
      codeBuilder.endBlock
      codeBuilder.endBlock
      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Error updating ' + dataModel.name + ' with ' +
                          varArray[0].name + ' = "' + ' + o.' + CodeNameStyling.stylePascal(varArray[0].name) + ', e);')
      codeBuilder.endBlock(';')
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlUpdate.new)
