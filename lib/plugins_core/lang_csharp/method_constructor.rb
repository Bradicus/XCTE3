##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin"

class XCTECSharp::MethodConstructor < XCTEPlugin
  def initialize
    @name = "method_constructor"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's constructor
  def render_function(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec
    fun = fp_params.fun_spec
    bld.add("///")
    bld.add("/// Constructor")
    bld.add("///")

    standard_class_name = XCTECSharp::Utils.instance.style_as_class(cls.get_u_name)

    bld.start_class(standard_class_name + "()")

    get_body(cls, bld, fun)

    bld.end_class
  end

  def get_declairation(cls, bld, _fun)
    bld.add("public " + XCTECSharp::Utils.instance.style_as_class(cls.get_u_name) + "();")
  end

  # No deps
  def process_dependencies(cls, fun); end

  def get_body(cls, bld, _fun)
    conDef = String.new
    varArray = []
    cls.model.getAllVarsFor(varArray)

    for var in varArray
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && !var.defaultValue.nil?
        bld.add(var.name << " = ")

        if var.vtype == "String"
          bld.same_line('"' << var.defaultValue << '";')
        else
          bld.same_line(var.defaultValue << ";")
        end

        bld.same_line("\t// " << var.comment) if !var.comment.nil?

        bld.add
      end
    end

    conDef
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodConstructor.new)
