##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a write meathod for a class
 
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodWriteUGP < XCTEPlugin
  
  def initialize
    @name = "method_writeugp"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end
  
  # Returns declairation string for this class's UGP write method
  def get_declaration(codeClass, cfg)
    return "        void write" << "(ug::io::StreamWriter* ugsw);\n"
  end  
  
  # Returns definition string for this class's UGP write method
  def get_definition(codeClass, cfg)
    writeDef = String.new
        
    writeDef << "/**\n* Writes this object from a stream\n*/\n"
    writeDef << "void " << codeClass.name << " :: write" + "(ug::io::StreamWriter* ugsw)\n"
    writeDef << "{\n"
        
    if codeClass.hasAnArray
      writeDef << "    unsigned int i;\n\n";
    end

    for par in codeClass.parentsList
      writeDef << "    " << par.name << "::write(ugsw);" << "\n"
    end
        
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE                
        if varSec.isStatic   # Ignore static variables
          writeDef << ""               
        elsif !varSec.isPointer                
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils::isPrimitive(varSec)                        
              writeDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
              writeDef << "        ugsw -> write" << XCTECpp::Utils::getTypeAbbrev(varSec)
              writeDef << "(" << varSec.name << "[i]);\n\n";                        
            else                        
              writeDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
              writeDef << "        " + varSec.name << "[i].write(ugsw);\n\n";
            end
          else # Not an array                    
            if XCTECpp::Utils::isPrimitive(varSec)
              writeDef << "    ugsw -> write" << XCTECpp::Utils::getTypeAbbrev(varSec)
              writeDef << "(" + varSec.name << ");\n"                        
            else                        
              writeDef << "    " << varSec.name << ".write(ugsw);\n";
            end
          end     
          
        elsif varSec.isPointer                
          writeDef << "    // " + varSec.name + " -> write(ugsw);\n"                
        else                
          writeDef << "\n"
        end
            
      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        writeDef << "    " << XCTECpp::Utils::getComment(varSec)          
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        writeDef << varSec.formatText
      end
    end
        
    writeDef << "}\n\n"
        
    return writeDef
  end 
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodWriteUGP.new)
