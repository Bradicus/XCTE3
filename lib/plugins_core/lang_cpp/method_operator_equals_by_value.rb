##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require "plugins_core/lang_cpp/x_c_t_e_cpp"

class XCTECpp::MethodOperatorEqualsByValue < XCTEPlugin
  def initialize
    @name = "method_operator_equals_by_value"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's equality assignment operator
  def render_declaration(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec
    fun = fp_params.fun_spec

    eqString = String.new

    bld.add("const " << Utils.instance.style_as_class(codeClass.name) << "& operator=" << "(const " << Utils.instance.style_as_class(codeClass.name))
    bld.same_line("& src" << Utils.instance.style_as_class(codeClass.name) << ");")
    bld.add

    return eqString
  end

  # Returns definition string for this class's equality assignment operator
  def render_function(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec
    fun = fp_params.fun_spec

    eqString = String.new
    longArrayFound = false

    styledCName = Utils.instance.style_as_class(codeClass.name)

    bld.add("/**")
    bld.add(" * Sets this object equal to incoming object")
    bld.add(" */")
    bld.start_class("const " + styledCName +
                    "& " + styledCName + " :: operator=(const " + styledCName + "& src" + styledCName + ");")

    #    if codeClass.has_an_array
    #      bld.add("    unsigned int i;\n");
    #    end

    for par in codeClass.base_classes
      bld.add("    " << par.name << "::operator=(src" + styledCName << ");")
    end

    varArray = []
    codeClass.getAllVarsFor(varArray)

    for var in varArray
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        fmtVarName = Utils.instance.get_styled_variable_name(var)
        if !var.isStatic # Ignore static variables
          if Utils.instance.is_primitive(var)
            if var.arrayElemCount.to_i > 0 # Array of primitives
              bld.add("memcpy(" << fmtVarName << ", ")
              bld.same_line("src" << styledCName << ".")
              bld.same_line(fmtVarName << ", ")
              bld.same_line("sizeof(" + Utils.instance.get_type_name(var.vtype) << ") * " << Utils.instance.get_size_const(var))
              bld.same_line(");")
            else
              bld.add(fmtVarName << " = src" << styledCName << "." << fmtVarName << ";")
            end
          elsif var.arrayElemCount > 0 # Not a primitive
            if !longArrayFound
              bld.add("unsigned int i;")
              bld.add
              longArrayFound = true
            end
            bld.start_block("for (i = 0; i < " << Utils.instance.get_size_const(var) << "; i++)")
            bld.add(fmtVarName + "[i] = src" + styledCName + "." + "[i];")
            bld.end_block # Array of objects
          else
            bld.add(fmtVarName + " = src" + styledCName + "." + fmtVarName + ";")
          end
        end
      elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        bld.add(Utils.instance.get_comment(var))
      elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        bld.add(var.formatText)
      end
    end

    bld.add
    bld.add("return(*this);")
    bld.end_block
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodOperatorEqualsByValue.new)
