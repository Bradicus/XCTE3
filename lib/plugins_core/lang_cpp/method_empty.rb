##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates an empty method with the specified function name
# and parameters

require 'code_elem_model.rb'
require 'lang_file.rb'

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodEmpty < XCTEPlugin  
  def initialize
    @name = "method_empty"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end
  
  # Returns declairation string for this empty method
  def get_declaration(fun, cfg)
    eDecl = String.new

    eDecl << "        "
    if fun.isVirtual
      eDecl << "virtual "
    end
        
    if fun.isStatic
      eDecl << "static "
    end

    if fun.returnValue.isConst
      eDecl << "const "
    end
        
    eDecl << XCTECpp::Utils::getTypeName(fun.returnValue.vtype) << " "
    eDecl << fun.name << "("

    for param in (0..(fun.parameters.size - 1))           
      if param != 0
        eDecl << ", "
      end
      
      eDecl << XCTECpp::Utils::getParamDec(fun.parameters[param])
    end
    
    eDecl << ")"

    if fun.isConst
      eDecl << " const";
    end

    eDecl << ";\n";
  end
  
  # Returns definition string for an empty method
  def get_definition(codeClass, fun)
    eDef = String.new

    # Skeleton of comment block
    eDef << "/**\n"
    eDef << "* \n"
    eDef << "* \n"
    
    for param in fun.parameters
      eDef << "* @param " << param.name << " \n"
    end
        
    if fun.returnValue.vtype != "void"
      eDef << "* \n* @return \n"
    end  
        
    eDef << "*/ \n"

    # Function body framework
    if fun.returnValue.isConst
      eDef << "const "
    end
        
    eDef << XCTECpp::Utils::getTypeName(fun.returnValue.vtype) << " "
    eDef << codeClass.name << " :: "
    eDef << fun.name << "("

    for param in (0..(fun.parameters.size - 1))            
      if param != 0
        eDef << ", "
      end

      eDef << XCTECpp::Utils::getParamDec(fun.parameters[param])
    end
        
    eDef << ")"

    if fun.isConst
      eDef << " const"        
    end
        
    eDef << "\n"

    eDef << "{\n"
    eDef << "    \n"
        
    if fun.returnValue.vtype != "void"
      eDef << "    return();\n"
    end
        
    eDef << "}\n\n"

    return eDef
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodEmpty.new)
