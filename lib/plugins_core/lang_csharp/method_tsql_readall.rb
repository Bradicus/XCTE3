##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_csharp/x_c_t_e_csharp.rb'

class XCTECSharp::MethodTsqlRetrieveAll < XCTEPlugin
  
  def initialize
    @name = "method_tsql_retrieve_all"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, genFun, cfg, codeBuilder)
    codeBuilder.add('/// <summary>')
    codeBuilder.add('/// Reads data set from sql database')
    codeBuilder.add('/// </summary>')

    standardClassName = XCTECSharp::Utils.instance.getStyledClassName(dataModel.name)

    codeBuilder.startClass("public IEnumerable<" + standardClassName + "> RetrieveAll(SqlTransaction trans)")

    get_body(dataModel, genClass, genFun, cfg, codeBuilder)
        
    codeBuilder.endClass
  end

  def get_declairation(dataModel, genClass, genFun, cfg, codeBuilder)
    codeBuilder.add("IEnumerable<" + dataModel.name + "> RetrieveAll(SqlTransaction trans);")
  end

  def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
    genClass.addInclude('System.Collections.Generic', 'IEnumerable')
    genClass.addInclude('System.Data.SqlClient', 'SqlTransaction')
  end

  def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(cfg, varArray)

    codeBuilder.add('List<' + dataModel.name + '> resultList = new List<' + dataModel.name + '>();')

    codeBuilder.add('string sql = @"SELECT ')

    codeBuilder.indent

    first = true;
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !first
          codeBuilder.sameLine(',')
        end
        first = false

        codeBuilder.add(CodeNameStyling.stylePascal(var.name))
      else
        if var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
      end
    end

    codeBuilder.unindent

    codeBuilder.add('FROM ' + dataModel.name + '";')


    codeBuilder.add

    codeBuilder.startBlock("try")
    codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))")

    codeBuilder.add

    codeBuilder.add('SqlDataReader results = cmd.ExecuteReader();')

    codeBuilder.startBlock('while(results.Read())')

    codeBuilder.add('var o = new ' + dataModel.name + '();')

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE && var.listType == nil && XCTECSharp::Utils.instance.isPrimitive(var)
        resultVal = 'results["' + XCTECSharp::Utils.instance.getStyledVariableName(var) + '"]'
        objVar = "o." + XCTECSharp::Utils.instance.getStyledVariableName(var)

        if var.nullable
            codeBuilder.add(objVar + ' = ' + resultVal + ' == DBNull.Value ? null : Convert.To' +
                                var.vtype + "(" + resultVal + ");")
        else
          codeBuilder.add(objVar + ' = Convert.To' +
                              var.vtype + "(" + resultVal + ");")
        end
      end
    end

    codeBuilder.endBlock
    codeBuilder.endBlock

    codeBuilder.endBlock
    codeBuilder.startBlock("catch(Exception e)")
    codeBuilder.add('throw new Exception("Error retrieving all items from ' + dataModel.name + '", e);')
    codeBuilder.endBlock(';')

    codeBuilder.add
    codeBuilder.add('return resultList;')
  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlRetrieveAll.new)
