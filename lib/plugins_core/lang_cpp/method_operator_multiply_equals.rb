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

class XCTECpp::MethodOperatorMultiplyEquals < XCTEPlugin

  def initialize
    @name = "method_operator_multiply_equals"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end

  # Returns declairation string for this class's equality assignment operator
  def get_declaration(codeClass, cfg)
    eqString = String.new

    eqString << "        const " << codeClass.name
    eqString << "& operator-=" << "(const " << codeClass.name
    eqString << " src" << codeClass.name << ");\n"

    return eqString
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg)
    eqString = String.new
    longArrayFound = false;

    eqString << "/**\n* Multiplies a " << codeClass.name << " from this one\n*/\n"
    eqString << "const " << codeClass.name
    eqString << "& " << codeClass.name << " :: operator*=" << "(const " << codeClass.name
    eqString << " src" + codeClass.name << ")\n"
    eqString << "{\n"

#    if codeClass.hasAnArray
#      eqString << "    unsigned int i;\n\n";
#    end

    for par in codeClass.parentsList
      eqString << "    " << par.name << "::operator*=(src" + codeClass.name << ");\n"
    end

    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
            if var.arrayElemCount > 0	# Array of objects
              if var.arrayElemCount > 10
                if !longArrayFound
                  eqString << "    unsigned int i;\n\n";
                  longArrayFound = true
                end
                eqString << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(var)
                eqString << "; i++)\n        "
                eqString << "        " << var.name << "[i] *= "
                eqString << "src" + codeClass.name << "."
                eqString << var.name << "[i];\n\n"
              else
                for i in 0..(var.arrayElemCount - 1)
                  eqString << "    " <<  var.name << "[" << i.to_s() << "] -= "
                  eqString << "src" + codeClass.name << "."
                  eqString << var.name << "[" << i.to_s() << "];\n"
                end
              end
            else
              eqString << "    " << var.name << " *= "
              eqString << "src" << codeClass.name << "."
              eqString << var.name << ";\n";
            end
        end

      elsif var.elementId == CodeElem::ELEM_COMMENT
        eqString << "    " << XCTECpp::Utils::getComment(var)
      elsif var.elementId == CodeElem::ELEM_FORMAT
        eqString << var.formatText
      end
    end

    eqString << "\n    return(*this);\n";
    eqString << "}\n\n";
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodOperatorMultiplyEquals.new)
