##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class
 
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

module XCTECpp
  class MethodEqualityAssign < XCTEPlugin
    
    def initialize
      @name = "method_equality_assign"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end 
    
    # Returns declairation string for this class's equality assignment operator
    def get_declaration(dataModel, genClass, funItem, hFile)
      eqString = String.new
        
      hFile.add(genClass.name)
      hFile.sameLine("(const " + genClass.name)
      hFile.sameLine("& src" + genClass.name + ");")
          
      hFile.add("const " + genClass.name)
      hFile.sameLine("& operator=" + "(const " + genClass.name)
      hFile.sameLine("& src" + genClass.name + ");\n")
    end

    def get_dependencies(dataModel, genClass, funItem, hFile)
    end
    
    # Returns definition string for this class's equality assignment operator
    def get_definition(dataModel, genClass, funItem, hFile)
      eqString = String.new
      longArrayFound = false;
      
      # First add copy constructor  
      hFile.genMultiComment(['Copy constructor']) 
      hFile.startFunction(genClass.name + " :: " + genClass.name + "(const " + genClass.name + "& src" + genClass.name + ")")
      hFile.add("operator=(src" + genClass.name + ");")
      hFile.endFunction
      
      hFile.genMultiComment(['Sets this object equal to incoming object']) 
      hFile.add("const " + genClass.name)
      hFile.sameLine("& " + genClass.name + " :: operator=" + "(const " + genClass.name)
      hFile.sameLine("& src" + genClass.name + ")")
      hFile.add("{")
      hFile.indent
          
  #    if genClass.hasAnArray
  #      hFile.add("    unsigned int i;"))
  #    end

      for par in genClass.baseClasses
        hFile.add(par.name + "::operator=(src" + genClass.name + ");")
      end

      varArray = Array.new
      dataModel.getAllVarsFor(varArray);

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE                
          if !var.isStatic   # Ignore static variables                
            if Utils.instance.isPrimitive(var)
              if var.arrayElemCount.to_i > 0	# Array of primitives
                hFile.add("memcpy(" + var.name + ", " + "src" + genClass.name + "." + var.name + ", ")
                hFile.sameLine("sizeof(" + Utils.instance.getTypeName(var.vtype) + ") * " + Utils.instance.getSizeConst(var))
                hFile.sameLine(");")
              else
                hFile.add(var.name + " = " + "src" + genClass.name + ".")
                hFile.sameLine(var.name + ";")
              end
            else	# Not a primitive
              if var.arrayElemCount > 0	# Array of objects
                  if !longArrayFound
                    hFile.add("    unsigned int i;")
                    longArrayFound = true
                  end
                hFile.add("for (i = 0; i < " + Utils.instance.getSizeConst(var) + "; i++)")
                hFile.indent
                hFile.add(var.name + "[i] = ")
                hFile.add("src" + genClass.name + ".")
                hFile.add(var.name + "[i];\n")
                hFile.unindent
              else
                hFile.add(var.name + " = src" + genClass.name + "." + var.name + ";")
              end
            end
          end
          
        elsif var.elementId == CodeElem::ELEM_COMMENT
          hFile.add(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          hFile.add(var.formatText)
        end
      end
          
      hFile.add("return(*this);")
      hFile.endFunction
    end        
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodEqualityAssign.new)
