##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a method for writing all information in 
# this class to a stream

require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodLogIt < XCTEPlugin
  
  def initialize
    @name = "method_log_it"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end  
  
  # Returns declairation string for this class's logIt method
  def get_declaration(codeClass, cfg)
    logItString = String.new
      
    logItString << "\n#ifdef _LOG_IT\n"
    logItString << "        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const;\n"
    logItString << "#else\n"
    logItString << "        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const{;};\n"
    logItString << "#endif\n"
      
    return logItString
  end 
  
  # Returns definition string for this class's logIt method
  def get_definition(codeClass, cfg)
    logItString = String.new
        
    logItString << "/**\n* Logs this class's info to a stream\n"
    logItString << "* \n"
    logItString << "* @param outStr The stream theis class is being logged to\n"
    logItString << "* @param indent The amount we we indent each line in the class output\n"
    logItString << "* @param logChildren Whether or not we will write objects side this object\n"
    logItString << "* to the debug stream\n"
    logItString << "*/\n";
            
    logItString << "#ifdef _LOG_IT\n"
    logItString << "void " << codeClass.name << " :: logIt(std::ostream &outStr, std::string indent, bool logChildren) const\n"
    logItString << "{\n"
        
    if codeClass.hasAnArray
      logItString << "    unsigned int i;\n\n"
    end
        
    logItString << "    outStr << indent << \" -- " << codeClass.name << " begin -- \" << std::endl;\n"

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE
        if !varSec.isPointer
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils::isPrimitive(varSec)
              logItString << "    outStr << indent << \"" << varSec.name << ": \";"                            
              logItString << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) << "; i++)\n"
              logItString << "        outStr << "
              logItString << varSec.name << "[i] << \"  \";\n"
              logItString << "    outStr << std::endl;\n\n"
            else
              logItString << "    outStr << indent << \"" << varSec.name << ": \";"
                            
              logItString << "\n    if (logChildren)\n"
              logItString << "        for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
              logItString << "            " << varSec.name << "[i].logIt(outStr,  indent + \"  \");\n\n"
              logItString << "        outStr << std::endl;\n\n"
            end
          else  # Not an array                
            if XCTECpp::Utils::isPrimitive(varSec)                        
              logItString << "    outStr << indent << \"" << varSec.name << ": \" << "
              logItString << varSec.name +  " << std::endl;\n"                        
            else                        
              logItString << "    outStr << indent << \"Object " << varSec.name << ": \";"
              logItString << "\n    if (logChildren)\n"
              logItString << "        " << varSec.name << ".logIt(outStr,  indent + \"  \");\n"
            end
          end  
        else
          logItString << "    outStr << indent << " << varSec.name << " << std::endl;\n"
        end
      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        logItString << "    " << XCTECpp::Utils::getComment(varSec);
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        logItString << varSec.formatText
      end
    end
 
    logItString << "    outStr << indent << \" -- " << codeClass.name << " end -- \" << std::endl;\n"
        
    logItString << "}\n"
    logItString << "#endif\n\n"
        
    return logItString
  end       
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodLogIt.new)
