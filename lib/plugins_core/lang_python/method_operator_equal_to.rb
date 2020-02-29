##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require 'plugins_core/lang_python/x_c_t_e_python.rb'

class XCTEPython::MethodOperatorEqualTo < XCTEPlugin

  def initialize
    @name = "method_operator_equal_to"
    @language = "python"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg)
    eqString = String.new
    longArrayFound = false
    seperator = ""

    eqString << "# Sets this object equal to incoming object\n"

    eqString << "def __eq__" << "(src" << codeClass.name << ")\n"

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    eqString << "    return(\n"

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0	# Array of primitives
              eqString << "        " << seperator << "@" << var.name << " == "
              eqString << "src" << codeClass.name << "."
              eqString << var.name << "\n"

              seperator = "&& "
            end
          end
        end
      end
    end


    eqString << "    )\n";
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPython::MethodOperatorEqualTo.new)
