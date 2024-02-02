##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a subtraction operator for a class

require 'plugins_core/lang_cpp/x_c_t_e_cpp'

class XCTECpp::MethodOperatorMinus < XCTEPlugin
  def initialize
    @name = 'method_operator_minus'
    @language = 'cpp'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's equality assignment operator
  def get_declaration(codeClass, _cfg)
    eqString = String.new

    eqString << '        const ' << codeClass.name
    eqString << ' operator-' << '(const ' << codeClass.name
    eqString << ' src' << codeClass.name << ") const;\n"

    return eqString
  end

  # Returns definition string for this class's equality assignment operator
  def render_function(codeClass, _cfg)
    eqString = String.new
    longArrayFound = false

    eqString << "/**\n* Returns the result of subtracting a " << codeClass.name << " from this one\n*/\n"
    eqString << 'const ' << codeClass.name
    eqString << ' ' << codeClass.name << ' :: operator-' << '(const ' << codeClass.name
    eqString << ' src' + codeClass.name << ") const\n"
    eqString << "{\n"

    #    if codeClass.has_an_array
    #      eqString << "    unsigned int i;\n\n";
    #    end

    eqString << '    ' << codeClass.name << " diff;\n\n"

    for par in codeClass.parentsList
      eqString << '    ' << par.name << '::operator-(src' + codeClass.name << ");\n"
    end

    varArray = []
    codeClass.getAllVarsFor(varArray)

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if !var.isStatic # Ignore static variables
          if var.arrayElemCount > 0	# Array of objects
            if var.arrayElemCount > 10
              if !longArrayFound
                eqString << "    unsigned int i;\n\n"
                longArrayFound = true
              end
              eqString << "\n    for (i = 0; i < " << XCTECpp::Utils.get_size_const(var)
              eqString << "; i++)\n        "
              eqString << '        diff.' << var.name << '[i] = '
              eqString << var.name << '[i] - '
              eqString << 'src' + codeClass.name << '.'
              eqString << var.name << "[i];\n\n"
            else
              for i in 0..(var.arrayElemCount - 1)
                eqString << '    diff.' << var.name << '[' << i.to_s() << '] = '
                eqString << var.name << '[' << i.to_s() << '] - '
                eqString << 'src' + codeClass.name << '.'
                eqString << var.name << '[' << i.to_s() << "];\n"
              end
            end
          else
            eqString << '    diff.' << var.name << ' = '
            eqString << var.name << ' - '
            eqString << 'src' << codeClass.name << '.'
            eqString << var.name << ";\n"
          end
        end

      elsif var.elementId == CodeElem::ELEM_COMMENT
        eqString << '    ' << XCTECpp::Utils.getComment(var)
      elsif var.elementId == CodeElem::ELEM_FORMAT
        eqString << var.formatText
      end
    end

    eqString << "\n    return(diff);\n"
    eqString << "}\n\n"
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodOperatorMinus.new)
