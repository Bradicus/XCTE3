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

class XCTECSharp::MethodConstructor < XCTEPlugin
  
  def initialize
    @name = "method_constructor"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end
  
  # Returns definition string for this class's constructor
  def get_definition(codeClass, cfg, codeBuilder)
    codeBuilder.add("/**")
    codeBuilder.add("* Reads data set from sql database")
    codeBuilder.add("*/")
      
    codeBuilder.startClass("readAll(SqlConnection con)")

    get_body(codeClass, cfg, codeBuilder)
        
    codeBuilder.endClass
  end

  def get_body(codeClass, cfg, codeBuilder)
    conDef = String.new
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(\"SELECT * FROM dbo.\")")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.defaultValue != nil
          codeBuilder.add(var.name << " = ")

          if var.vtype == "String"
            codeBuilder.sameLine("\"" << var.defaultValue << "\";")
          else
            codeBuilder.sameLine(var.defaultValue << ";")
          end

          if var.comment != nil
            codeBuilder.sameLine("\t// " << var.comment)
          end

          codeBuilder.add
        end
      end
    end

    codeBuilder.endBlock

    return(conDef)
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodConstructor.new)
