##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodConstructor < XCTEPlugin
  
  def initialize
    @name = "method_constructor"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end
  
  # Returns declairation string for this class's constructor
  def get_declaration(codeClass, cfg, codeGen)
    codeGen.add(codeClass.name + "();")
  end

  # Returns declairation string for this class's constructor
  def get_declaration_inline(codeClass, cfg, codeGen)
    codeGen.startFuction(codeClass.name + "()")
    codeStr << get_body(codeClass, cfg, codeGen)
    codeGen.endFunction
  end
  
  # Returns definition string for this class's constructor
  def get_definition(codeClass, cfg, codeGen)
    codeGen.add("/**")
    codeGen.add("* Constructor")
    codeGen.add("*/")
      
    classDef = String.new  
    classDef << codeClass.name << " :: " << codeClass.name << "()"
    codeGen.startClass(classDef)

    get_body(codeClass, cfg, codeGen)
        
    codeGen.endClass
  end

  def get_body(codeClass, cfg, codeGen)
    conDef = String.new
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

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
XCTEPlugin::registerPlugin(XCTECpp::MethodConstructor.new)
