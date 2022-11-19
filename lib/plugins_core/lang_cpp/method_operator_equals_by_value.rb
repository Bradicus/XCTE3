##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

class XCTECpp::MethodOperatorEqualsByValue < XCTEPlugin
  def initialize
    @name = "method_operator_equals_by_value"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's equality assignment operator
  def get_declaration(codeClass, cfg, bld)
    eqString = String.new

    bld.add("const " << Utils.instance.getStyledClassName(codeClass.name) << "& operator=" << "(const " << Utils.instance.getStyledClassName(codeClass.name))
    bld.sameLine("& src" << Utils.instance.getStyledClassName(codeClass.name) << ");")
    bld.add

    return eqString
  end

  # Returns definition string for this class's equality assignment operator
  def get_definition(codeClass, cfg, bld)
    eqString = String.new
    longArrayFound = false

    styledCName = Utils.instance.getStyledClassName(codeClass.name)

    bld.add("/**")
    bld.add(" * Sets this object equal to incoming object")
    bld.add(" */")
    bld.startClass("const " + styledCName +
                   "& " + styledCName + " :: operator=(const " + styledCName + "& src" + styledCName + ");")

    #    if codeClass.hasAnArray
    #      bld.add("    unsigned int i;\n");
    #    end

    for par in codeClass.baseClasses
      bld.add("    " << par.name << "::operator=(src" + styledCName << ");")
    end

    varArray = Array.new
    codeClass.getAllVarsFor(varArray)

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        fmtVarName = Utils.instance.getStyledVariableName(var)
        if !var.isStatic # Ignore static variables
          if Utils.instance.isPrimitive(var)
            if var.arrayElemCount.to_i > 0 # Array of primitives
              bld.add("memcpy(" << fmtVarName << ", ")
              bld.sameLine("src" << styledCName << ".")
              bld.sameLine(fmtVarName << ", ")
              bld.sameLine("sizeof(" + Utils.instance.getTypeName(var.vtype) << ") * " << Utils.instance.getSizeConst(var))
              bld.sameLine(");")
            else
              bld.add(fmtVarName << " = src" << styledCName << "." << fmtVarName << ";")
            end
          else # Not a primitive
            if var.arrayElemCount > 0 # Array of objects
              if !longArrayFound
                bld.add("unsigned int i;")
                bld.add
                longArrayFound = true
              end
              bld.startBlock("for (i = 0; i < " << Utils.instance.getSizeConst(var) << "; i++)")
              bld.add(fmtVarName + "[i] = src" + styledCName + "." + "[i];")
              bld.endBlock
            else
              bld.add(fmtVarName + " = src" + styledCName + "." + fmtVarName + ";")
            end
          end
        end
      elsif var.elementId == CodeElem::ELEM_COMMENT
        bld.add(Utils.instance.getComment(var))
      elsif var.elementId == CodeElem::ELEM_FORMAT
        bld.add(var.formatText)
      end
    end

    bld.add
    bld.add("return(*this);")
    bld.endBlock
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodOperatorEqualsByValue.new)
