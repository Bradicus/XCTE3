##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"

class XCTECSharp::MethodConstructor < XCTEPlugin
  def initialize
    @name = "method_constructor"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's constructor
  def get_definition(cls, bld, fun)
    bld.add("///")
    bld.add("/// Constructor")
    bld.add("///")

    standardClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.getUName())

    bld.startClass(standardClassName + "()")

    get_body(cls, bld, fun)

    bld.endClass
  end

  def get_declairation(cls, bld, fun)
    bld.add("public " + XCTECSharp::Utils.instance.getStyledClassName(cls.getUName()) + "();")
  end

  # No deps
  def process_dependencies(cls, bld, fun)
  end

  def get_body(cls, bld, fun)
    conDef = String.new
    varArray = Array.new
    cls.model.getAllVarsFor(varArray)

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.defaultValue != nil
          bld.add(var.name << " = ")

          if var.vtype == "String"
            bld.sameLine('"' << var.defaultValue << '";')
          else
            bld.sameLine(var.defaultValue << ";")
          end

          if var.comment != nil
            bld.sameLine("\t// " << var.comment)
          end

          bld.add
        end
      end
    end

    return(conDef)
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodConstructor.new)
