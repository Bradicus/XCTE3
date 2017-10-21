##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'

class XCTECSharp::MethodConstructor < XCTEPlugin
  
  def initialize
    @name = "method_constructor"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, fun, cfg, codeBuilder)
    codeBuilder.add("///")
    codeBuilder.add("/// Constructor")
    codeBuilder.add("///")

    standardClassName = XCTECSharp::Utils.instance.getStyledClassName(dataModel.name)

    codeBuilder.startClass(standardClassName + "()")

    get_body(dataModel, genClass, fun, cfg, codeBuilder)
        
    codeBuilder.endClass
  end
  
  def get_declairation(dataModel, genClass, genFun, cfg, codeBuilder)
    codeBuilder.add("public " + XCTECSharp::Utils.instance.getStyledClassName(dataModel.name) + "();")
  end
  
  # No deps
  def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
  end

  def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.defaultValue != nil
          codeBuilder.add(var.name << " = ")

          if var.vtype == "String"
            codeBuilder.sameLine('"' << var.defaultValue << '";')
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

    return(conDef)
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodConstructor.new)
