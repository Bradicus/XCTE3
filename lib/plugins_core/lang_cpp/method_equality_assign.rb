##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

module XCTECpp
  class MethodEqualityAssign < XCTEPlugin
    def initialize
      @name = "method_equality_assign"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's equality assignment operator
    def get_declaration(cls, funItem, hFile)
      eqString = String.new

      hFile.add(Utils.instance.getStyledClassName(cls.getUName()))
      hFile.sameLine("(const " + Utils.instance.getStyledClassName(cls.getUName()))
      hFile.sameLine("& src" + Utils.instance.getStyledClassName(cls.getUName()) + ");")

      hFile.add("const " + Utils.instance.getStyledClassName(cls.getUName()))
      hFile.sameLine("& operator=" + "(const " + Utils.instance.getStyledClassName(cls.getUName()))
      hFile.sameLine("& src" + Utils.instance.getStyledClassName(cls.getUName()) + ");\n")
    end

    def process_dependencies(cls, funItem, hFile)
    end

    # Returns definition string for this class's equality assignment operator
    def get_definition(cls, funItem, hFile)
      eqString = String.new
      longArrayFound = false

      styledCName = Utils.instance.getStyledClassName(cls.getUName())

      # First add copy constructor
      hFile.genMultiComment(["Copy constructor"])
      hFile.startFunction(styledCName + " :: " + styledCName + "(const " + styledCName + "& src" + styledCName + ")")
      hFile.add("operator=(src" + styledCName + ");")
      hFile.endFunction

      hFile.genMultiComment(["Sets this object equal to incoming object"])
      hFile.add("const " + styledCName)
      hFile.sameLine("& " + styledCName + " :: operator=" + "(const " + styledCName)
      hFile.sameLine("& src" + styledCName + ")")
      hFile.add("{")
      hFile.indent

      #    if cls.hasAnArray
      #      hFile.add("    unsigned int i;"))
      #    end

      for par in cls.baseClasses
        hFile.add(Utils.instance.getStyledClassName(par.name) + "::operator=(src" + styledCName + ");")
      end

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          fmtVarName = Utils.instance.getStyledVariableName(var)
          if !var.isStatic # Ignore static variables
            if Utils.instance.isPrimitive(var)
              if var.arrayElemCount.to_i > 0 # Array of primitives
                hFile.add("memcpy(" + fmtVarName + ", " + "src" + styledCName + "." + fmtVarName + ", ")
                hFile.sameLine("sizeof(" + Utils.instance.getTypeName(var) + ") * " + Utils.instance.getSizeConst(var))
                hFile.sameLine(");")
              else
                hFile.add(fmtVarName + " = " + "src" + styledCName + ".")
                hFile.sameLine(fmtVarName + ";")
              end
            else # Not a primitive
              if var.arrayElemCount > 0 # Array of objects
                if !longArrayFound
                  hFile.add("    unsigned int i;")
                  longArrayFound = true
                end
                hFile.add("for (i = 0; i < " + Utils.instance.getSizeConst(var) + "; i++)")
                hFile.indent
                hFile.add(fmtVarName + "[i] = ")
                hFile.sameLine("src" + styledCName + ".")
                hFile.sameLine(fmtVarName + "[i];\n")
                hFile.unindent
              else
                hFile.add(fmtVarName + " = src" + styledCName + "." + fmtVarName + ";")
              end
            end
          end
        elsif var.elementId == CodeElem::ELEM_COMMENT
          hFile.add(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          hFile.add(var.formatText)
        end
      end

      hFile.add("return(*this);")
      hFile.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodEqualityAssign.new)
