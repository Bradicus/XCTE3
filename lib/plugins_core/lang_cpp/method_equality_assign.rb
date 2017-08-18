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
  end 
  
  # Returns declairation string for this class's equality assignment operator
  def get_declaration(codeClass, cfg)
    eqString = String.new
      
    codeBuilder.add("        " << codeClass.name)
    codeBuilder.add("(const " << codeClass.name)
    codeBuilder.add("& src" << codeClass.name << ");")
        
    codeBuilder.add("        const " << codeClass.name)
    codeBuilder.add("& operator=" << "(const " << codeClass.name)
    codeBuilder.add("& src" << codeClass.name << ");\n")
          
    return eqString
  end
  
  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg)
    eqString = String.new
    longArrayFound = false;
    
    # First add copy constructor   
    codeBuilder.add("/**")
    codeBuilder.add("* Copy constructor")
    codeBuilder.add("*/")
    codeBuilder.startFuction(codeClass.name + " :: " + codeClass.name + "(const " + codeClass.name + "& src" + codeClass.name + ")")
    codeBuilder.add("operator=(src" << codeClass.name << ");")
    codeBuilder.endFunction
    codeBuilder.add
    
    codeBuilder.add("/**\n* Sets this object equal to incoming object\n*/")
    codeBuilder.add("const " << codeClass.name)
    codeBuilder.sameLine("& " << codeClass.name << " :: operator=" << "(const " << codeClass.name)
    codeBuilder.sameLine("& src" + codeClass.name << ")")
    codeBuilder.add("{")
    codeBuilder.indent
        
#    if codeClass.hasAnArray
#      codeBuilder.add("    unsigned int i;"))
#    end

    for par in codeClass.parentsList
      codeBuilder.add(par.name + "::operator=(src" + codeClass.name << ");")
    end

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE                
        if !var.isStatic   # Ignore static variables                
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i > 0	# Array of primitives
              codeBuilder.add("memcpy(" + var.name + ", " + "src" + codeClass.name + "." + var.name + ", ")
              codeBuilder.sameLine("sizeof(" + XCTECpp::Utils::getTypeName(var.vtype) << ") * " << XCTECpp::Utils::getSizeConst(var))
              codeBuilder.sameLine(");")
            else
              codeBuilder.add(var.name + " = " + "src" + codeClass.name + ".")
              codeBuilder.sameLine(var.name << ";")
            end
          else	# Not a primitive
            if var.arrayElemCount > 0	# Array of objects
                if !longArrayFound
                  codeBuilder.add("    unsigned int i;")
                  longArrayFound = true
                end
              codeBuilder.add("for (i = 0; i < " + XCTECpp::Utils::getSizeConst(var) + "; i++)")
              codeBuilder.indent
              codeBuilder.add(var.name << "[i] = ")
              codeBuilder.add("src" + codeClass.name << ".")
              codeBuilder.add(var.name << "[i];\n")
              codeBuilder.unindent
            else
              codeBuilder.add(var.name + " = src" + codeClass.name + "." + var.name + ";")
            end
          end
        end
        
      elsif var.elementId == CodeElem::ELEM_COMMENT
        codeBuilder.add(XCTECpp::Utils::getComment(var))
      elsif var.elementId == CodeElem::ELEM_FORMAT
        codeBuilder.add(var.formatText)
      end
    end
        
    codeBuilder.add("return(*this);")
    codeBuilder.endClass
  end        
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodEqualityAssign.new)
