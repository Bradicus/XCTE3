##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a mothod for reading class data from a RakNet
# bit stream

require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodReadRak < XCTEPlugin
  
   
  def initialize
    @name = "method_read_rak"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end
  
  # Returns declairation string for this class's UGP write method
  def get_declaration(codeClass, cfg)
    return "        void readRak" << "(RakNet::BitStream& rBits);\n"
  end  
  
  # Returns definition string for this class's UGP write method
  def get_definition(codeClass, cfg)
    readDef = String.new
        
    readDef << "/**\n* Reads this object from a stream\n*/\n"
    readDef << "void " << codeClass.name << " :: readRak" + "(RakNet::BitStream& rBits)\n"
    readDef << "{\n"
        
    if codeClass.hasAnArray
      readDef << "    unsigned int i;\n\n";
    end
    
    if (codeClass.hasVariableType("String"))
      readDef << "    unsigned short strLen;\n\n";
    end
        
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray)
    # CodeStructure::CodeElemClass.getVarsFor(codeClass.varGroup, cfg, varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE                
        if varSec.isStatic   # Ignore static variables
          readDef << ""               
        elsif !varSec.isPointer                
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils::isPrimitive(varSec)
              if (varSec.vtype == "String")
                readDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
                readDef << "    {\n"
                readDef << "        rBits.Read(strLen);\n"
                readDef << "        if (strLen > 0)\n"
                readDef << "        {\n"
                readDef << "            " << varSec.name << "[i].resize(strLen);\n"
                readDef << "            rBits.Read(&(" << varSec.name << "[i][0]), strLen));\n";                
                readDef << "        }\n"
                readDef << "        else\n"
                readDef << "            " << varSec.name << "[i].clear();\n"
                readDef << "    }\n\n"
              else                      
                readDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
                readDef << "        rBits.Read(" << varSec.name << "[i]);\n\n";  
              end
            else                        
              readDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
              readDef << "        " + varSec.name << "[i].readRak(rBits);\n\n";
            end
          else # Not an array                    
            if XCTECpp::Utils::isPrimitive(varSec)
              if (varSec.vtype == "String")               
                readDef << "    rBits.Read(strLen);\n"
                readDef << "    if (strLen > 0)\n"
                readDef << "    {\n"
                readDef << "        " << varSec.name << ".resize(strLen);\n"
                readDef << "        rBits.Read(&(" << varSec.name << "[0]), strLen);\n";
                readDef << "    }\n"
                readDef << "    else\n"
                readDef << "        " << varSec.name << ".clear();\n"
              else              
                readDef << "    rBits.Read(" << varSec.name << ");\n"                        
              end
            end
          end     
          
        elsif varSec.isPointer                
          readDef << "    // " + varSec.name + " -> readRak(rBits);\n"                
        else                
          readDef << "\n"
        end
            
      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        readDef << "    " << XCTECpp::Utils::getComment(varSec)          
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        readDef << varSec.formatText
      end
    end
        
    readDef << "}\n\n"
        
    return readDef 
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodReadRak.new)
