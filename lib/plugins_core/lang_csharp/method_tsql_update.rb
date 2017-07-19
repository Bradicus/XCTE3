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
  def get_definition(dataModel, genClass, cfg, codeBuilder)
    codeBuilder.add("///")
    codeBuilder.add("/// Create new record for this model")
    codeBuilder.add("///")

    codeBuilder.startClass("public Enumerable<" + dataModel.name + "> Create(SqlTransaction trans, " + dataModel.name + " o)")

    get_body(dataModel, genClass, cfg, codeBuilder)

    codeBuilder.endClass
  end

  def get_declairation(dataModel, genClass, cfg, codeBuilder)
    codeBuilder.add("public Enumerable<" + dataModel.name + "> Create(SqlTransaction trans, " + dataModel.name + " o);")
  end

  def get_body(dataModel, genClass, cfg, codeBuilder)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(cfg, varArray)

    codeBuilder.add('string sql = @"UPDATE ' + dataModel.name + '(')

    codeBuilder.indent

    first = true;
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !first
          codeBuilder.sameLine(',')
        end
        first = false;

        codeBuilder.add(CodeNameStyling.stylePascal(var.name))
      else
        if var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
      end
    end

    codeBuilder.unindent
    codeBuilder.add(") VALUES (")
    codeBuilder.indent

    first = true;
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !first
          codeBuilder.sameLine(',')
        end
        first = false;

        codeBuilder.add('@' + CodeNameStyling.stylePascal(var.name))
      else
        if var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
      end
    end

    codeBuilder.unindent
    codeBuilder.add(')";')

    codeBuilder.add

    codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql)")

    codeBuilder.add('var newId = cmd.ExecuteScalar();')
    codeBuilder.add("o." + varArray[0].name + ' = newId;')
    codeBuilder.endBlock
  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlUpdate.new)
