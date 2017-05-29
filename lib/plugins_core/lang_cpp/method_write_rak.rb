##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a mothod for writing class data to a RakNet
# bit stream
 
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'
require 'x_c_t_e_plugin.rb'

class XCTECpp::MethodWriteRak < XCTEPlugin
   
  def initialize
    @name = "method_write_rak"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end
  
  # Returns declairation string for this class's UGP write method
  def get_declaration(codeClass, cfg)
    return "        void writeRak" << "(RakNet::BitStream& rBits);\n"
  end  
  
  # Returns definition string for this class's UGP write method
  def get_definition(codeClass, cfg)
    writeDef = String.new
        
    writeDef << "/**\n* Writes this object to a bit stream\n*/\n"
    writeDef << "void " << codeClass.name << " :: writeRak" + "(RakNet::BitStream& rBits)\n"
    writeDef << "{\n"
        
    if codeClass.hasAnArray
      writeDef << "    unsigned int i;\n\n";
    end
    
    if (codeClass.hasVariableType("String"))
      writeDef << "    unsigned short strLen;\n\n";
    end
        
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray)

    # CodeStructure::CodeElemClass.getVarsFor(codeClass.varGroup, cfg, varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE                
        if varSec.isStatic   # Ignore static variables
          writeDef << ""               
        elsif !varSec.isPointer                
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils::isPrimitive(varSec)     
              if (varSec.vtype == "String")
                writeDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
                writeDef << "    {\n"
                writeDef << "        strLen = (unsigned short)" << varSec.name << "[i].size();\n"
                writeDef << "        rBits.Write(strLen);\n"
                writeDef << "        if (strLen > 0)\n"
                writeDef << "            rBits.Write(&(" << varSec.name << "[i][0]), strLen));\n";
                writeDef << "    }\n\n"
              else
                writeDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
                writeDef << "        rBits.Write(" << varSec.name << "[i]);\n\n";                        
              end
            else  # Array of non-primitives                    
              writeDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
              writeDef << "        " + varSec.name << "[i].writeRak(rBits);\n\n";
            end
          else # Not an array                    
            if XCTECpp::Utils::isPrimitive(varSec)  
              if (varSec.vtype == "String")   
                writeDef << "    strLen = (unsigned short)" << varSec.name << ".size();\n"
                writeDef << "    rBits.Write(strLen);\n"
                writeDef << "    if (strLen > 0)\n"
                writeDef << "        rBits.Write(&(" << varSec.name << "[0]), strLen);\n\n";              
              else              
                writeDef << "    rBits.Write(" << varSec.name << ");\n"
              end
            else                        
              writeDef << "    " << varSec.name << ".writeRak(rBits);\n";
            end
          end     
          
        elsif varSec.isPointer                
          writeDef << "    // " + varSec.name + " -> writeRak(rBits);\n"                
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
XCTEPlugin::registerPlugin(XCTECpp::MethodWriteRak.new)
