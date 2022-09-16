##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

module XCTECpp
  class XCTECpp::MethodOperatorEqualTo < XCTEPlugin
    def initialize
      @name = "method_operator_equal_to"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's equality assignment operator
    def get_declaration(cls, funItem, codeBuilder)
      eqString = String.new

      codeBuilder.add("bool operator==" << "(const " << cls.name)
      codeBuilder.sameLine(eqString << " src" << cls.name << ") const;")

      return eqString
    end

    def process_dependencies(cls, funItem, codeBuilder)
    end

    # Returns definition string for this class's equality assignment operator
    def get_definition(cls, funItem, codeBuilder)
      longArrayFound = false
      seperator = ""

      codeBuilder.add("/**")
      codeBuilder.add("* Sets this object equal to incoming object")
      codeBuilder.add("*/")
      codeBuilder.startClass("bool " + cls.name + " :: operator==" + "(const " + cls.name + " src" + cls.name + ") const")

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      codeBuilder.add("return(")
      codeBuilder.indent

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !var.isStatic # Ignore static variables
            if (Utils.instance.isPrimitive(var))
              if var.arrayElemCount.to_i == 0 # Array of primitives
                codeBuilder.add(seperator << Utils.instance.getStyledVariableName(var) << " == ")
                codeBuilder.sameLine("src" << cls.name << ".")
                codeBuilder.sameLine(Utils.instance.getStyledVariableName(var))

                seperator = "&& "
              end
            end
          end
        end
      end

      codeBuilder.unindent

      codeBuilder.add(");")
      codeBuilder.endBlock
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodOperatorEqualTo.new)
