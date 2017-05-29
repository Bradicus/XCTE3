##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class
 
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodEqualityAssign < XCTEPlugin
  
  def initialize
    @name = "method_equality_assign"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end 
  
  # Returns declairation string for this class's equality assignment operator
  def get_declaration(codeClass, cfg)
    eqString = String.new
      
    codeGen.add("        " << codeClass.name)
    codeGen.add("(const " << codeClass.name)
    codeGen.add("& src" << codeClass.name << ");")
        
    codeGen.add("        const " << codeClass.name) 
    codeGen.add("& operator=" << "(const " << codeClass.name) 
    codeGen.add("& src" << codeClass.name << ");\n")
          
    return eqString
  end
  
  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg)
    eqString = String.new
    longArrayFound = false;
    
    # First add copy constructor   
    codeGen.add("/**")
    codeGen.add("* Copy constructor")
    codeGen.add("*/")
    codeGen.startFuction(codeClass.name + " :: " + codeClass.name + "(const " + codeClass.name + "& src" + codeClass.name + ")")
    codeGen.add("operator=(src" << codeClass.name << ");")
    codeGen.endFunction
    codeGen.add
    
    codeGen.add("/**\n* Sets this object equal to incoming object\n*/")
    codeGen.add("const " << codeClass.name)
    codeGen.sameLine("& " << codeClass.name << " :: operator=" << "(const " << codeClass.name) 
    codeGen.sameLine("& src" + codeClass.name << ")")
    codeGen.add("{")
    codeGen.indent
        
#    if codeClass.hasAnArray
#      codeGen.add("    unsigned int i;"))
#    end

    for par in codeClass.parentsList
      codeGen.add(par.name + "::operator=(src" + codeClass.name << ");")
    end

    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE                
        if !var.isStatic   # Ignore static variables                
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i > 0	# Array of primitives
              codeGen.add("memcpy(" + var.name + ", " + "src" + codeClass.name + "." + var.name + ", ")
              codeGen.sameLine("sizeof(" + XCTECpp::Utils::getTypeName(var.vtype) << ") * " << XCTECpp::Utils::getSizeConst(var))
              codeGen.sameLine(");")
            else
              codeGen.add(var.name + " = " + "src" + codeClass.name + ".")
              codeGen.sameLine(var.name << ";")
            end
          else	# Not a primitive
            if var.arrayElemCount > 0	# Array of objects
                if !longArrayFound
                  codeGen.add("    unsigned int i;")
                  longArrayFound = true
                end
              codeGen.add("for (i = 0; i < " + XCTECpp::Utils::getSizeConst(var) + "; i++)")
              codeGen.indent
              codeGen.add(var.name << "[i] = ")
              codeGen.add("src" + codeClass.name << ".")
              codeGen.add(var.name << "[i];\n")
              codeGen.unindent
            else
              codeGen.add(var.name + " = src" + codeClass.name + "." + var.name + ";")
            end
          end
        end
        
      elsif var.elementId == CodeElem::ELEM_COMMENT
        codeGen.add(XCTECpp::Utils::getComment(var))
      elsif var.elementId == CodeElem::ELEM_FORMAT
        codeGen.add(var.formatText)
      end
    end
        
    codeGen.add("return(*this);")
    codeGen.endClass
  end        
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodEqualityAssign.new)
