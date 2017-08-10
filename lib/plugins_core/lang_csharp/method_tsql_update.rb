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

class XCTECSharp::MethodTsqlUpdate < XCTEPlugin

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

    codeBuilder.startClass("public void Update(SqlTransaction trans, " + dataModel.name + " o)")

    get_body(dataModel, genClass, genFun, cfg, codeBuilder)

    codeBuilder.endClass
  end

  def get_declairation(dataModel, genClass, genFun, cfg, codeBuilder)
    codeBuilder.add("void Update(SqlTransaction trans, " + dataModel.name + " o);")
  end

  def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
    genClass.addInclude('System.Data.SqlClient', 'SqlTransaction')
  end
  
  def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(cfg, varArray)

    codeBuilder.add('string sql = @"UPDATE ' + dataModel.name + ' SET ')

    codeBuilder.indent

    count = 0
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if count > 1
          codeBuilder.sameLine(',')
		end
        if count > 0
		  codeBuilder.add(CodeNameStyling.stylePascal(var.name) + " = @" + CodeNameStyling.stylePascal(var.name))
        end
      elsif var.elementId == CodeElem::ELEM_FORMAT
        codeBuilder.add(var.formatText)
      end
	  count += 1
    end

    codeBuilder.unindent
    codeBuilder.add('WHERE ' + CodeNameStyling.stylePascal(varArray[0].name) +
		" = @" + CodeNameStyling.stylePascal(varArray[0].name)	+ '";')

    codeBuilder.add

    codeBuilder.startBlock("try")
    codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))")

    first = true
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        codeBuilder.add('cmd.Parameters.AddWithValue("@' + CodeNameStyling.stylePascal(var.name) +
                            '", o.' + CodeNameStyling.stylePascal(var.name) + ');')
      else
        if var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
      end
      first = false
    end

    codeBuilder.add('cmd.ExecuteScalar();')
    codeBuilder.endBlock
    codeBuilder.endBlock
    codeBuilder.startBlock("catch(Exception e)")
    codeBuilder.add('throw new Exception("Error updating ' + dataModel.name + ' with ' +
                        varArray[0].name + ' = "' + ' + o.' + CodeNameStyling.stylePascal(varArray[0].name) + ', e);')
    codeBuilder.endBlock(';')
  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlUpdate.new)
