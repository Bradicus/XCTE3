##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a subtraction operator for a class

require "plugins_core/lang_cpp/x_c_t_e_cpp"

class XCTECpp::MethodOperatorMinus < XCTEPlugin
  def initialize
    @name = "method_operator_minus"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's equality assignment operator
  def render_declaration(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec
    fun = fp_params.fun_spec

    eqString = String.new

    eqString << "        const " << cls.name
    eqString << " operator-" << "(const " << cls.name
    eqString << " src" << cls.name << ") const;\n"

    return eqString
  end

  # Returns definition string for this class's equality assignment operator
  def render_function(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec
    fun = fp_params.fun_spec

    eqString = String.new
    longArrayFound = false

    eqString << "/**\n* Returns the result of subtracting a " << cls.name << " from this one\n*/\n"
    eqString << "const " << cls.name
    eqString << " " << cls.name << " :: operator-" << "(const " << cls.name
    eqString << " src" + cls.name << ") const\n"
    eqString << "{\n"

    #    if cls.has_an_array
    #      eqString << "    unsigned int i;\n\n";
    #    end

    eqString << "    " << cls.name << " diff;\n\n"

    for par in cls.parentsList
      eqString << "    " << par.name << "::operator-(src" + cls.name << ");\n"
    end

    varArray = []
    cls.getAllVarsFor(varArray)

    for var in varArray
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        if !var.isStatic # Ignore static variables
          if var.arrayElemCount > 0 # Array of objects
            if var.arrayElemCount > 10
              if !longArrayFound
                eqString << "    unsigned int i;\n\n"
                longArrayFound = true
              end
              eqString << "\n    for (i = 0; i < " << XCTECpp::Utils.get_size_const(var)
              eqString << "; i++)\n        "
              eqString << "        diff." << var.name << "[i] = "
              eqString << var.name << "[i] - "
              eqString << "src" + cls.name << "."
              eqString << var.name << "[i];\n\n"
            else
              for i in 0..(var.arrayElemCount - 1)
                eqString << "    diff." << var.name << "[" << i.to_s() << "] = "
                eqString << var.name << "[" << i.to_s() << "] - "
                eqString << "src" + cls.name << "."
                eqString << var.name << "[" << i.to_s() << "];\n"
              end
            end
          else
            eqString << "    diff." << var.name << " = "
            eqString << var.name << " - "
            eqString << "src" << cls.name << "."
            eqString << var.name << ";\n"
          end
        end
      elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        eqString << "    " << XCTECpp::Utils.get_comment(var)
      elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        eqString << var.formatText
      end
    end

    eqString << "\n    return(diff);\n"
    eqString << "}\n\n"
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodOperatorMinus.new)
