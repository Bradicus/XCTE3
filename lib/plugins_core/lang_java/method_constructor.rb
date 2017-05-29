##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_java/x_c_t_e_java.rb'

class XCTEJava::MethodConstructor < XCTEPlugin
  
  def initialize
    @name = "method_constructor"
    @language = "java"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end
  
  # Returns definition string for this class's constructor
  def get_definition(codeClass, cfg)
    conDef = String.new
    indent = "    "
                
    conDef << indent << "/**\n"
    conDef << indent << "* Constructor\n"
    conDef << indent << "*/\n"
        
    conDef << indent << codeClass.name << "()\n"
    conDef << indent << "{\n";
        
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.defaultValue != nil
          conDef << indent << "    " << var.name << " = " 
                        
          if var.vtype == "String"
            conDef << "\"" << var.defaultValue << "\";"                    
          else
            conDef << var.defaultValue << ";"
          end
          
          if var.comment != nil
            conDef << "\t// " << var.comment
          end          
          
          conDef << "\n"
        end
      end
    end
        
    conDef << indent << "}\n\n";

    return(conDef);
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodConstructor.new)
