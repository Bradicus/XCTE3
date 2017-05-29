##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a method for writing all information in 
# this class to a stream

require 'plugins_core/lang_java/x_c_t_e_java.rb'

class XCTEJava::MethodLogIt < XCTEPlugin
  
  def initialize
    @name = "method_log_it"
    @language = "java"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end  

  # Returns definition string for this class's logIt method
  def get_definition(codeClass, cfg)
    logItString = String.new
    indent = String.new("    ");
        
    logItString << indent << "/**\n" << indent << "* Logs this class's info to a stream\n"
    logItString << indent << "* \n"
    logItString << indent << "* @param outStr The stream theis class is being logged to\n"
    logItString << indent << "* @param indent The amount we we indent each line in the class output\n"
    logItString << indent << "* @param logChildren Whether or not we will write objects side this object\n"
    logItString << indent << "* to the debug stream\n"
    logItString << indent << "*/\n";
            
    logItString << indent << "void logIt(PrintStream pStream, String indent, boolean logChildren)\n"
    logItString << indent << "{\n"
        
    if codeClass.hasAnArray
      logItString << indent << "    int i;\n\n"
    end
        
    logItString << indent << "    pStream.println(indent + \" -- " << codeClass.name << " begin -- \");\n"
        
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.isPointer
          if var.arrayElemCount > 0
            if XCTECpp::Utils::isPrimitive(var)
              logItString << indent << "    pStream.print(indent + \"" << var.name << ": \");\n"
              logItString << indent << "    for (i = 0; i < " << var.name + ".length; i++)\n"
              logItString << indent << "        pStream.print(" << var.name << "[i] + \"  \");\n"
              logItString << indent << "    pStream.println();\n\n"
            else
              logItString << indent << "    pStream.println(indent + \"" << var.name << ": \");"
                            
              logItString << indent << "    if (logChildren)\n"
              logItString << indent << "        for (i = 0; i < " << var.name + ".length; i++)\n"
              logItString << indent << "            " << var.name << "[i].logIt(outStr,  indent + \"  \");\n\n"
              logItString << indent << "        pStream.println();\n\n"
            end
          else  # Not an array                
            if XCTECpp::Utils::isPrimitive(var)
              logItString << indent << "    pStream.println(indent + \"" << var.name << ": \" + " << var.name << ");\n"
            else                        
              logItString << indent << "    pStream.println(indent + \"Object " << var.name << ": \");"
              logItString << indent << "    if (logChildren)\n"
              logItString << indent << "        " << var.name << ".logIt(outStr,  indent + \"  \");\n"
            end
          end  
        else
          #logItString << indent << "    pStream.println(indent + " << varSec.name << ");\n"
        end
      elsif var.elementId == CodeElem::ELEM_COMMENT
        logItString << indent << "    " << XCTEJava::Utils::getComment(var);
      elsif var.elementId == CodeElem::ELEM_FORMAT
        logItString << indent << var.formatText
      end
    end
 
    logItString << indent << "    pStream.println(indent + \" -- " << codeClass.name << " end -- \");\n"
        
    logItString << indent << "}\n\n"
        
    return logItString
  end       
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodLogIt.new)
