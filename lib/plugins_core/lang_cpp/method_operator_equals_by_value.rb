##

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
  end

  # Returns declairation string for this class's equality assignment operator
  def get_declaration(codeClass, cfg, codeBuilder)
    eqString = String.new

    codeBuilder.add("const " << codeClass.name << "& operator=" << "(const " << codeClass.name)
    codeBuilder.sameLine("& src" << codeClass.name << ");")
    codeBuilder.add

    return eqString
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg, codeBuilder)
    eqString = String.new
    longArrayFound = false;

    codeBuilder.add("/**")
    codeBuilder.add(" * Sets this object equal to incoming object")
    codeBuilder.add(" */")
    codeBuilder.startClass("const " + codeClass.name + "& " + codeClass.name + " :: operator=(const " + codeClass.name + "& src" + codeClass.name + ");")
    
#    if codeClass.hasAnArray
#      codeBuilder.add("    unsigned int i;\n");
#    end

    for par in codeClass.baseClasses
      codeBuilder.add("    " << par.name << "::operator=(src" + codeClass.name << ");")
    end

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i > 0	# Array of primitives
              codeBuilder.add("    memcpy(" << var.name << ", ")
              codeBuilder.sameLine("src" << codeClass.name << ".")
              codeBuilder.sameLine(var.name << ", ")
              codeBuilder.sameLine("sizeof(" + XCTECpp::Utils::getTypeName(var.vtype) << ") * " << XCTECpp::Utils::getSizeConst(var))
              codeBuilder.sameLine(");")
            else
              codeBuilder.add(var.name << " = src" << codeClass.name << "." << var.name << ";\n")
            end
          else	# Not a primitive
            if var.arrayElemCount > 0	# Array of objects
                if !longArrayFound
                  codeBuilder.add("unsigned int i;")
                  codeBuilder.add
                  longArrayFound = true
                end
              codeBuilder.startBlock("for (i = 0; i < " << XCTECpp::Utils::getSizeConst(var) << "; i++)")
              codeBuilder.add(var.name + "[i] = src" + codeClass.name + "." + "[i];")
              codeBuilder.endBlock
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

    codeBuilder.add
    codeBuilder.add("return(*this);")
    codeBuilder.endBlock
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodOperatorEqualsByValue.new)
