##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodDefine < XCTEPlugin

  def initialize
    @name = "method_define"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's define function
  def get_declaration(codeClass, cfg, codeBuilder)
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    eqString = String.new
    seperator = ""
    codeBuilder.add("void define(")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0	# Ignore arrays
              codeBuilder.sameLine(seperator + XCTECpp::Utils::getTypeName(var.vtype) + " ")
              codeBuilder.sameLine("new" << XCTECpp::Utils::getCapitalizedFirst(var.name))
              codeBuilder.sameLine(seperator = ", ")
            end
          end
        end
      end
    end

    codeBuilder.sameLine(");")

    return eqString
  end

  # Returns declairation string for this class's define function
  def get_declaration_inline(codeClass, cfg)
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    eqString = String.new
    seperator = ""
    codeBuilder.add("void define(")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0	# Ignore arrays
              codeBuilder.sameLine(seperator << XCTECpp::Utils::getTypeName(var.vtype) << " ")
              codeBuilder.sameLine("new" << XCTECpp::Utils::getCapitalizedFirst(var.name))
              seperator = ", "
            end
          end
        end
      end
    end

    codeBuilder.sameLine(")")
    codeBuilder.startBlock
    get_body(codeClass, cfg, codeBuilder)
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg, codeBuilder)
    seperator = ""
    longArrayFound = false;
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    codeBuilder.add("/**\n* Defines the variables in an object\n*/")
    codeBuilder.add("void " << codeClass.name << " :: define(")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0	# Ignore arrays
              codeBuilder.sameLine(seperator << XCTECpp::Utils::getTypeName(var.vtype) << " ")
              codeBuilder.sameLine("new" << XCTECpp::Utils::getCapitalizedFirst(var.name))
              seperator = ", "
            end
          end
        end
      end
    end

    codeBuilder.sameLine(")")
    codeBuilder.startBlock()

#    if codeClass.hasAnArray
#      eqString << "    unsigned int i;\n\n";
#    end

    eqString << get_body(codeClass, cfg, "    ")

    codeBuilder.endBlock
    codeBuilder.add
  end

  ## Get body of function
  def get_body(codeClass, cfg, codeBuilder)

    eqString = String.new
    seperator = ""
    longArrayFound = false;
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
              eqString << indent << var.name << " = "
              eqString << "new" << XCTECpp::Utils::getCapitalizedFirst(var.name) << ";\n"
            end
          end
        end
    end

    return(eqString)
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodDefine.new)
