##

#
# Copyright XCTE Contributors
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
    def get_declaration(cls, bld, funItem)
      bld.add(Utils.instance.getStyledClassName(cls.getUName()) + "();")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, bld, funItem)
      bld.startFuction(Utils.instance.getStyledClassName(cls.getUName()) + "()")
      codeStr << get_body(cls, funItem, hFile)
      bld.endFunction
    end

    def process_dependencies(cls, bld, funItem)
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, funItem)
      bld.add("/**")
      bld.add("* Constructor")
      bld.add("*/")

      classDef = String.new
      classDef << Utils.instance.getStyledClassName(cls.getUName()) << " :: " << Utils.instance.getStyledClassName(cls.getUName()) << "()"
      bld.startClass(classDef)

      get_body(cls, bld, funItem)

      bld.endFunction
    end

    def get_body(cls, bld, funItem)
      conDef = String.new

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
        if var.defaultValue != nil
          bld.add(Utils.instance.getStyledVariableName(var) << " = ")

          if var.vtype == "String"
            bld.sameLine("\"" << var.defaultValue << "\";")
          else
            bld.sameLine(var.defaultValue << ";")
          end

          if var.comment != nil
            bld.sameLine("\t// " << var.comment)
          end

          bld.add
        end

        if var.init != nil
          bld.add(var.init)
        end
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodConstructor.new)
