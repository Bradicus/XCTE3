##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodZero < XCTEPlugin

  def initialize
    @name = "method_zero"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's equality assignment operator
  def get_declaration(codeClass, cfg)
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    eqString = String.new
    seperator = ""
    eqString << "        void zero();\n"

    return eqString
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg)
    eqString = String.new
    seperator = ""
    longArrayFound = false;
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    eqString << "/**\n* Defines the variables in an object\n*/\n"
    eqString << "void " << codeClass.name << " :: zero()\n"
    eqString << "{\n"

#    if codeClass.hasAnArray
#      eqString << "    unsigned int i;\n\n";
#    end

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
              eqString << "    " << var.name << " = " << XCTECpp::Utils::getZero(var) << ";\n"
            end
          end
        end
    end

    eqString << "}\n\n";
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodZero.new)
