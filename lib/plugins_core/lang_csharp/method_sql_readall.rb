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
  def get_definition(codeClass, cfg, codeGen)
    codeGen.add("/**")
    codeGen.add("* Reads data set from sql database")
    codeGen.add("*/")
      
    codeGen.startClass("readAll(SqlConnection con)")

    get_body(codeClass, cfg, codeGen)
        
    codeGen.endClass
  end

  def get_body(codeClass, cfg, codeGen)
    conDef = String.new
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    codeGen.startBlock("using(SqlCommand cmd = new SqlCommand(\"SELECT * FROM dbo.\")")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.defaultValue != nil
          codeGen.add(var.name << " = ")

          if var.vtype == "String"
            codeGen.sameLine("\"" << var.defaultValue << "\";")
          else
            codeGen.sameLine(var.defaultValue << ";")
          end

          if var.comment != nil
            codeGen.sameLine("\t// " << var.comment)
          end

          codeGen.add
        end
      end
    end

    return(conDef)
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodConstructor.new)
