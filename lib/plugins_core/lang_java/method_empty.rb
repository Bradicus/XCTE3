##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates an empty method with the specified function name
# and parameters

require 'code_elem_model.rb'
require 'lang_file.rb'

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_java/x_c_t_e_java.rb'

class XCTEJava::MethodEmpty < XCTEPlugin
  
  def initialize
    @name = "method_empty"
    @language = "java"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns definition string for an empty method
  def get_definition(fun, cfg)
    eDef = String.new
    
    indent = String.new("    ")

    # Skeleton of comment block
    eDef << indent << "/**\n"
    eDef << indent << "* \n"
    eDef << indent << "* \n"
    
    for param in fun.parameters
      eDef << indent << "* @param " << param.name << " \n"
    end
        
    if fun.returnValue.vtype != "void"
      eDef << indent << "* \n" << indent << "* @return \n"
    end  
        
    eDef << indent << "*/\n"
    
    eDef << indent

    # Function body framework
    if fun.isStatic
      eDef << "static "
    end
    
    if fun.returnValue.isConst
      eDef << "const "
    end
        
    eDef << XCTEJava::Utils::getTypeName(fun.returnValue.vtype) << " "
    eDef << fun.name << "("

    for param in (0..(fun.parameters.size - 1))            
      if param != 0
        eDef << ", "
      end

      eDef << XCTEJava::Utils::getParamDec(fun.parameters[param])
    end
        
    eDef << ")"
        
    eDef << "\n"

    eDef << indent << "{\n"
    eDef << indent << "    \n"
        
    if fun.returnValue.vtype != "void"
      eDef << indent << "    return();\n"
    end
        
    eDef << indent << "}\n\n"

    return eDef
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodEmpty.new)
