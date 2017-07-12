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

class XCTECpp::MethodOperatorEqualsByValue < XCTEPlugin

  def initialize
    @name = "method_operator_equals_by_value"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end

  # Returns declairation string for this class's equality assignment operator
  def get_declaration(codeClass, cfg, codeGen)
    eqString = String.new

    codeGen.add("const " << codeClass.name << "& operator=" << "(const " << codeClass.name)
    codeGen.sameLine("& src" << codeClass.name << ");")
    codeGen.add

    return eqString
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg, codeGen)
    eqString = String.new
    longArrayFound = false;

    codeGen.add("/**")
    codeGen.add(" * Sets this object equal to incoming object")
    codeGen.add(" */")
    codeGen.startClass("const " + codeClass.name + "& " + codeClass.name + " :: operator=(const " + codeClass.name + "& src" + codeClass.name + ");")
    
#    if codeClass.hasAnArray
#      codeGen.add("    unsigned int i;\n");
#    end

    for par in codeClass.baseClasses
      codeGen.add("    " << par.name << "::operator=(src" + codeClass.name << ");")
    end

    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i > 0	# Array of primitives
              codeGen.add("    memcpy(" << var.name << ", ")
              codeGen.sameLine("src" << codeClass.name << ".")
              codeGen.sameLine(var.name << ", ")
              codeGen.sameLine("sizeof(" + XCTECpp::Utils::getTypeName(var.vtype) << ") * " << XCTECpp::Utils::getSizeConst(var))
              codeGen.sameLine(");")
            else
              codeGen.add(var.name << " = src" << codeClass.name << "." << var.name << ";\n")
            end
          else	# Not a primitive
            if var.arrayElemCount > 0	# Array of objects
                if !longArrayFound
                  codeGen.add("unsigned int i;")
                  codeGen.add
                  longArrayFound = true
                end
              codeGen.startBlock("for (i = 0; i < " << XCTECpp::Utils::getSizeConst(var) << "; i++)")
              codeGen.add(var.name + "[i] = src" + codeClass.name + "." + "[i];")
              codeGen.endBlock
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

    codeGen.add
    codeGen.add("return(*this);")
    codeGen.endBlock
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodOperatorEqualsByValue.new)
