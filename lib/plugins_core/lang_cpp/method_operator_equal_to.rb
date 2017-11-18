##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodOperatorEqualTo < XCTEPlugin

  def initialize
    @name = "method_operator_equal_to"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's equality assignment operator
  def get_declaration(codeClass, cfg)
    eqString = String.new

    eqString << "        bool operator==" << "(const " << codeClass.name
    eqString << " src" << codeClass.name << ") const;\n"

    return eqString
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg)
    eqString = String.new
    longArrayFound = false;
    seperator = ""

    eqString << "/**\n* Sets this object equal to incoming object\n*/\n"
    eqString << "bool " << codeClass.name << " :: operator==" << "(const " << codeClass.name
    eqString << " src" + codeClass.name << ") const\n"
    eqString << "{\n"

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    eqString << "    return(\n"

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0	# Array of primitives
              eqString << "        " << seperator << Utils.instance.getStyledVariableName(var) << " == "
              eqString << "src" << codeClass.name << "."
              eqString << Utils.instance.getStyledVariableName(var) << "\n"

              seperator = "&& "
            end
          end
        end
      end
    end


    eqString << "    );\n";
    eqString << "}\n\n";
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodOperatorEqualTo.new)
