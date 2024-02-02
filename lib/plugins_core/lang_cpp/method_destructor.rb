##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a destructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodDestructor < XCTEPlugin  
  def initialize
    @name = "method_destructor"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns declairation string for this class's destructor   
  def get_declaration(codeClass, cfg)
    return "        ~" << codeClass.name << "();\n"
  end

  # Returns declairation string for this class's destructor
  def get_declaration_inline(codeClass, cfg)
    return "        ~" << codeClass.name << "() {};\n"
  end
  
  # Returns definition string for this class's destructor
  def render_function(codeClass, cfg)
    desDef = String.new
    
    desDef << "/**\n"
    desDef << "* Destructor\n"
    desDef << "*/\n"
        
    desDef << codeClass.name + " :: ~" << codeClass.name << "()\n"
    desDef << "{\n"        
    desDef << "}\n\n"
        
    return desDef
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodDestructor.new)
