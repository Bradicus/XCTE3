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

class XCTECpp::MethodDefine < XCTEPlugin

  def initialize
    @name = "method_define"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end

  # Returns declairation string for this class's define function
  def get_declaration(codeClass, cfg, codeGen)
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    eqString = String.new
    seperator = ""
    codeGen.add("void define(")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0	# Ignore arrays
              codeGen.sameLine(seperator + XCTECpp::Utils::getTypeName(var.vtype) + " ")
              codeGen.sameLine("new" << XCTECpp::Utils::getCapitalizedFirst(var.name))
              codeGen.sameLine(seperator = ", ")
            end
          end
        end
      end
    end

    codeGen.sameLine(");")

    return eqString
  end

  # Returns declairation string for this class's define function
  def get_declaration_inline(codeClass, cfg)
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    eqString = String.new
    seperator = ""
    codeGen.add("void define(")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0	# Ignore arrays
              codeGen.sameLine(seperator << XCTECpp::Utils::getTypeName(var.vtype) << " ")
              codeGen.sameLine("new" << XCTECpp::Utils::getCapitalizedFirst(var.name))
              seperator = ", "
            end
          end
        end
      end
    end

    codeGen.sameLine(")")
    codeGen.startBlock
    get_body(codeClass, cfg, codeGen)
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg, codeGen)
    seperator = ""
    longArrayFound = false;
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    codeGen.add("/**\n* Defines the variables in an object\n*/")
    codeGen.add("void " << codeClass.name << " :: define(")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic   # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0	# Ignore arrays
              codeGen.sameLine(seperator << XCTECpp::Utils::getTypeName(var.vtype) << " ")
              codeGen.sameLine("new" << XCTECpp::Utils::getCapitalizedFirst(var.name))
              seperator = ", "
            end
          end
        end
      end
    end

    codeGen.sameLine(")")
    codeGen.startBlock()

#    if codeClass.hasAnArray
#      eqString << "    unsigned int i;\n\n";
#    end

    eqString << get_body(codeClass, cfg, "    ")

    codeGen.endBlock
    codeGen.add
  end

  ## Get body of function
  def get_body(codeClass, cfg, codeGen)

    eqString = String.new
    seperator = ""
    longArrayFound = false;
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

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
