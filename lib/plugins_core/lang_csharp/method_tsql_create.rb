##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin.rb'
require 'code_name_styling.rb'
require 'plugins_core/lang_csharp/x_c_t_e_csharp.rb'
require 'plugins_core/lang_csharp/utils.rb'

class XCTECSharp::MethodTsqlCreate < XCTEPlugin

  def initialize
    @name = "method_tsql_create"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, genFun, cfg, codeBuilder)
    codeBuilder.add("///")
    codeBuilder.add("/// Create new record for this model")
    codeBuilder.add("///")

    codeBuilder.startFunction("public void Create(SqlTransaction trans, " + XCTECSharp::Utils.instance.getStyledClassName(dataModel.name) + " o)")

    get_body(dataModel, genClass, genFun, cfg, codeBuilder)

    codeBuilder.endFunction
  end

  def get_declairation(dataModel, genClass, genFun, cfg, codeBuilder)
    codeBuilder.add("void Create(SqlTransaction trans, " + dataModel.name + " o);")
  end

  def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
    genClass.addInclude('System', 'Exception')
    genClass.addInclude('System.Data.SqlClient', 'SqlTransaction')
  end

  def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(varArray)

    codeBuilder.add('string sql = @"INSERT INTO ' + XCTETSql::Utils.instance.getStyledClassName(dataModel.name) + '(')

    codeBuilder.indent

    seperator = '';
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if (var.identity == nil)
          codeBuilder.sameLine(seperator)

          codeBuilder.add(
            XCTETSql::Utils.instance.getStyledVariableName(var, genClass.varPrefix)
          )
        end
      else
        if var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
      end
      seperator = ',';
    end

    codeBuilder.unindent
    codeBuilder.add(") VALUES (")
    codeBuilder.indent

    first = true;
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if (var.identity == nil)
          if !first
            codeBuilder.sameLine(',')
          end
          first = false;

          codeBuilder.add('@' +  XCTECSharp::Utils.instance.getStyledVariableName(var))
        end
      else
        if var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
      end
    end

    codeBuilder.unindent
    codeBuilder.add(')";')

    codeBuilder.add

    codeBuilder.startBlock("try")
    codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, trans.Connection, trans))")

    Utils.instance.addNonIdentityParams(dataModel, genClass, codeBuilder)

    codeBuilder.add

    identVar = dataModel.getIdentityVar();

    if identVar != nil
      codeBuilder.add('var newId = cmd.ExecuteScalar();')
      codeBuilder.add("o." + Utils.instance.getStyledVariableName(identVar) + 
                      ' = Convert.To' + identVar.vtype + '(newId);')
    end

    codeBuilder.endBlock
    codeBuilder.endBlock
    codeBuilder.startBlock("catch(Exception e)")
    codeBuilder.add('throw new Exception("Error inserting ' + 
        XCTETSql::Utils.instance.getStyledClassName(dataModel.name) + ' into database", e);')
    codeBuilder.endBlock(';')
  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlCreate.new)
