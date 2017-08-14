##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a read meathod for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodReadUGP < XCTEPlugin
  
  def initialize
    @name = "method_readugp"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns declairation string for this class's UGP read method
  def get_declaration(codeClass, cfg)
    return "        void read" << "(ug::io::StreamReader* ugsr);\n"
  end
  
  # Returns definition string for this class's UGP read method
  def get_definition(codeClass, cfg)
    readDef = String.new
        
    readDef << "/**\n* Reads this object from a stream\n*/\n"
    readDef << "void " << codeClass.name << " :: read" + "(ug::io::StreamReader* ugsr)\n"
    readDef << "{\n"
        
    if codeClass.hasAnArray
      readDef << "    unsigned int i;\n\n"
    end

    for par in codeClass.parentsList
      readDef << "    " << par.name << "::read(ugsr);" << "\n"
    end
        
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE                
        if varSec.isStatic   # Ignore static variables
          readDef << ""               
        elsif !varSec.isPointer                
          if varSec.arrayElemCount > 0                    
            if XCTECpp::Utils::isPrimitive(varSec)                        
              readDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
              readDef << "        ugsr -> read" << XCTECpp::Utils::getTypeAbbrev(varSec)
              readDef << "(" << varSec.name << "[i]);\n\n";                        
            else                        
              readDef << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
              readDef << "        " + varSec.name << "[i].read(ugsr);\n\n";
            end
          else # Not an array                    
            if XCTECpp::Utils::isPrimitive(varSec)
              readDef << "    ugsr -> read" << XCTECpp::Utils::getTypeAbbrev(varSec)
              readDef << "(" + varSec.name << ");\n"                        
            else                        
              readDef << "    " << varSec.name << ".read(ugsr);\n";
            end
          end     
          
        elsif varSec.isPointer                
          readDef << "    // " + varSec.name + " -> read(ugsr);\n"                
        else                
          readDef << "\n"
        end
            
      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        readDef << "    " << XCTECpp::Utils::getComment(varSec)          
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        readDef << varSec.formatText
      end
    end
        
    readDef << "}\n\n";
        
    return readDef;
  end      
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodReadUGP.new)
