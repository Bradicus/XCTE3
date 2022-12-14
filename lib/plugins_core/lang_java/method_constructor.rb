##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_java/x_c_t_e_java.rb"

class XCTEJava::MethodConstructor < XCTEPlugin
  def initialize
    @name = "method_constructor"
    @language = "java"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's constructor
  def get_definition(cls, bld, cfg)
    bld.add("/**")
    bld.add("* Constructor")
    bld.add("*/")

    bld.startFunction(cls.name + "()")

    eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
      if var.defaultValue != nil
        bld.add(var.name + " = ")

        if var.vtype == "String"
          bld.sameLine('"' + var.defaultValue + "\";")
        else
          bld.sameLine(var.defaultValue + ";")
        end

        if var.comment != nil
          bld.sameLine("\t// " + var.comment)
        end
      end
    }))

    bld.endFunction
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodConstructor.new)
