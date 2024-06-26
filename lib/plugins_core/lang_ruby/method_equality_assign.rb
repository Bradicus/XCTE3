##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require 'plugins_core/lang_ruby/x_c_t_e_ruby'

class XCTERuby::MethodEqualityAssign < XCTEPlugin
  def initialize
    @name = 'method_equality_assign'
    @language = 'ruby'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's equality assignment operator
  def render_function(codeClass, _cfg)
    eqString = String.new
    longArrayFound = false

    eqString << "/**\n* Sets this object equal to incoming object\n*/\n"
    eqString << 'def =' << '(src' + codeClass.name << ")\n"

    #    if codeClass.has_an_array
    #      eqString << "    unsigned int i;\n\n";
    #    end

    for par in codeClass.parentsList
      eqString << '    ' << par.name << '::operator=(src' + codeClass.name << ");\n"
    end

    varArray = []
    codeClass.getAllVarsFor(varArray)

    for var in varArray
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        if !var.isStatic # Ignore static variables
          if XCTECpp::Utils.is_primitive(var)
            if var.arrayElemCount.to_i > 0	# Array of primitives
              eqString << "\n    for i in 0..@" << var.name << '.size' << "\n"
              eqString << '        ' << var.name << '[i] = src' << codeClass.name << '[i]' << "\n"
              eqString << "      end\n\n"
            else
              eqString << '    ' << var.name << ' = '
              eqString << 'src' << codeClass.name << '.'
              eqString << var.name << "\n"
            end
          elsif var.arrayElemCount > 0	# Not a primitive
            eqString << "\n    for i in 0..@" << var.name << '.size' << "\n"
            eqString << '        ' << var.name << '[i] = src' << codeClass.name << '[i]' << "\n"
            eqString << "      end\n\n"	# Array of objects
          else
            eqString << '    ' << var.name << ' = '
            eqString << 'src' << codeClass.name << '.'
            eqString << var.name << "\n"
          end
        end

      elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        eqString << '    ' << XCTECpp::Utils.get_comment(var)
      elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        eqString << var.formatText
      end
    end

    eqString << "\n    return(self);\n"
    eqString << "end  # =\n\n"
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTERuby::MethodEqualityAssign.new)
