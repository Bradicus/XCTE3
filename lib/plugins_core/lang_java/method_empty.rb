##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an empty method with the specified function name
# and parameters

require "code_elem_model.rb"
require "lang_file.rb"

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_java/x_c_t_e_java.rb"

class XCTEJava::MethodEmpty < XCTEPlugin
  def initialize
    @name = "method_empty"
    @language = "java"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for an empty method
  def get_definition(fun, bld, cfg)

    # Skeleton of comment block
    bld.add("/**")
    bld.add("* ")

    for param in fun.parameters
      bld.add("* @param " + param.name)
    end

    if fun.returnValue.vtype != "void"
      bld.add("* \n" + indent + "* @return ")
    end

    bld.add("*/")

    bld.add

    # Function body framework
    if fun.isStatic
      bld.sameLine("static ")
    end

    if fun.returnValue.isConst
      bld.sameLine("const ")
    end

    bld.sameLine(XCTEJava::Utils::getTypeName(fun.returnValue.vtype) << " ")
    bld.sameLine(fun.name << "(")

    for param in (0..(fun.parameters.size - 1))
      if param != 0
        bld.sameLine(", ")
      end

      bld.sameLine(XCTEJava::Utils::getParamDec(fun.parameters[param]))
    end

    bld.sameLine(")")

    bld.separate

    bld.add("{")

    if fun.returnValue.vtype != "void"
      bld.iadd("return();")
    end

    bld.add("}")
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodEmpty.new)
