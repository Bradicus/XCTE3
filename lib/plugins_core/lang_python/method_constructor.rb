##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_python/x_c_t_e_python.rb"

module XCTEPython
  class MethodConstructor < XCTEPlugin
    def initialize
      @name = "method_constructor"
      @language = "python"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, fun, rend)
      conDef = String.new

      rend.add("# Initializer")

      rend.startFunction("def __init__(self)")

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.isStatic != true
          if var.defaultValue != nil
            rend.add("self." << Utils.instance.getStyledVariableName(var) + " = ")

            if var.vtype == "String"
              rend.sameLine('"' + var.defaultValue + '"')
            else
              rend.sameLine(var.defaultValue)
            end

            if var.comment != nil
              rend.sameLine("\t# " + var.comment)
            end

            rend.add
          else
            rend.add("self." << Utils.instance.getStyledVariableName(var) + " = None")
          end
        end
      end

      rend.endBlock("# init")
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPython::MethodConstructor.new)
