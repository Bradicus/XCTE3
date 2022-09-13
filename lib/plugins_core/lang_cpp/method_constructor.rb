##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

module XCTECpp
  class MethodConstructor < XCTEPlugin
    def initialize
      @name = "method_constructor"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's constructor
    def get_declaration(cls, funItem, codeBuilder)
      codeBuilder.add(Utils.instance.getStyledClassName(cls.getUName()) + "();")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, funItem, codeBuilder)
      codeBuilder.startFuction(Utils.instance.getStyledClassName(cls.getUName()) + "()")
      codeStr << get_body(cls, funItem, hFile)
      codeBuilder.endFunction
    end

    def process_dependencies(cls, funItem, codeBuilder)
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, funItem, codeBuilder)
      codeBuilder.add("/**")
      codeBuilder.add("* Constructor")
      codeBuilder.add("*/")

      classDef = String.new
      classDef << Utils.instance.getStyledClassName(cls.getUName()) << " :: " << Utils.instance.getStyledClassName(cls.getUName()) << "()"
      codeBuilder.startClass(classDef)

      get_body(cls, funItem, codeBuilder)

      codeBuilder.endFunction
    end

    def get_body(cls, funItem, codeBuilder)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if var.defaultValue != nil
            codeBuilder.add(Utils.instance.getStyledVariableName(var) << " = ")

            if var.vtype == "String"
              codeBuilder.sameLine("\"" << var.defaultValue << "\";")
            else
              codeBuilder.sameLine(var.defaultValue << ";")
            end

            if var.comment != nil
              codeBuilder.sameLine("\t// " << var.comment)
            end

            codeBuilder.add
          end

          if var.init != nil
            codeBuilder.add(var.init)
          end
        end
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodConstructor.new)
