##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

class XCTECpp::MethodDefine < XCTEPlugin
  def initialize
    @name = "method_define"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's define function
  def get_declaration(codeClass, bld)
    varArray = Array.new
    codeClass.getAllVarsFor(varArray)

    eqString = String.new
    seperator = ""
    bld.add("void define(")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0 # Ignore arrays
              bld.sameLine(seperator + XCTECpp::Utils::getTypeName(var.vtype) + " ")
              bld.sameLine("new" << XCTECpp::Utils::getCapitalizedFirst(var.name))
              bld.sameLine(seperator = ", ")
            end
          end
        end
      end
    end

    bld.sameLine(");")

    return eqString
  end

  # Returns declairation string for this class's define function
  def get_declaration_inline(codeClass, cfg)
    varArray = Array.new
    codeClass.getAllVarsFor(varArray)

    eqString = String.new
    seperator = ""
    bld.add("void define(")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0 # Ignore arrays
              bld.sameLine(seperator << XCTECpp::Utils::getTypeName(var.vtype) << " ")
              bld.sameLine("new" << XCTECpp::Utils::getCapitalizedFirst(var.name))
              seperator = ", "
            end
          end
        end
      end
    end

    bld.sameLine(")")
    bld.startBlock
    get_body(codeClass, bld)
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, bld)
    seperator = ""
    longArrayFound = false
    varArray = Array.new
    codeClass.getAllVarsFor(varArray)

    bld.add("/**\n* Defines the variables in an object\n*/")
    bld.add("void " << codeClass.name << " :: define(")

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic # Ignore static variables
          if XCTECpp::Utils::isPrimitive(var)
            if var.arrayElemCount.to_i == 0 # Ignore arrays
              bld.sameLine(seperator << XCTECpp::Utils::getTypeName(var.vtype) << " ")
              bld.sameLine("new" << XCTECpp::Utils::getCapitalizedFirst(var.name))
              seperator = ", "
            end
          end
        end
      end
    end

    bld.sameLine(")")
    bld.startBlock()

    #    if codeClass.hasAnArray
    #      eqString << "    unsigned int i;\n\n";
    #    end

    eqString << get_body(codeClass, "    ")

    bld.endBlock
    bld.add
  end

  ## Get body of function
  def get_body(codeClass, bld)
    eqString = String.new
    seperator = ""
    longArrayFound = false
    varArray = Array.new
    codeClass.getAllVarsFor(varArray)

    varArray = Array.new
    codeClass.getAllVarsFor(varArray)

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic # Ignore static variables
          if Utils.instance.isPrimitive(var)
            eqString << indent << var.name << " = "
            eqString << "new" << Utils.instance.getStyledVariableName(var) << ";\n"
          end
        end
      end
    end

    return(eqString)
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodDefine.new)
