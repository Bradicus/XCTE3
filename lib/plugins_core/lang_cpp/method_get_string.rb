##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a method that returns the class variables as a string
# this class to a stream

require 'plugins_core/lang_cpp/x_c_t_e_cpp'

class XCTECpp::MethodGetString < XCTEPlugin
  def initialize
    @name = 'method_get_string'
    @language = 'cpp'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's logIt method
  def get_declaration(_codeClass, _cfg)
    methodString = String.new

    methodString << "\n#ifdef _LOG_IT\n"
    methodString << "        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const;\n"
    methodString << "#else\n"
    methodString << "        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const{;};\n"
    methodString << "#endif\n"

    return methodString
  end

  # Returns definition string for this class's logIt method
  def render_function(codeClass, _cfg)
    methodString = String.new

    methodString << "/**\n* Returns a string representing object data\n"
    methodString << "*/\n"

    methodString << 'std::string ' << codeClass.name << " :: getString() const\n"
    methodString << "{\n"

    if codeClass.has_an_array
      methodString << "    unsigned int i;\n\n"
    end

    methodString << "    std::stringstream outStr;\n\n"

    varArray = []
    codeClass.getAllVarsFor(varArray)

    for varSec in varArray
      if varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        if !varSec.isPointer
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils.is_primitive(varSec)
              methodString << '    outStr << "' << varSec.name << ': {";'
              methodString << "\n    for (i = 0; i < " << XCTECpp::Utils.get_size_const(varSec) << "; i++)\n"
              methodString << '        outStr << '
              methodString << varSec.name << "[i] << \"  \";\n"
              methodString << "    outStr << \"}\"\n\n"
            else
              methodString << '    outStr << indent << "' << varSec.name << ': [";'

              methodString << '        for (i = 0; i < ' << XCTECpp::Utils.get_size_const(varSec) + "; i++)\n"
              methodString << '            ' << varSec.name << "[i].logIt(outStr,  indent + \"  \");\n\n"
              methodString << "        outStr << \" ] \";\n\n"
            end
          elsif XCTECpp::Utils.is_primitive(varSec) # Not an array
            methodString << '    outStr << "' << varSec.name << ': " << '
            methodString << varSec.name +  " << \"  \";\n"
          else
            methodString << '    outStr << "Object ' << varSec.name << ': ";'
            methodString << '        ' << varSec.name << ".getString();\n"
          end
        else
          methodString << '    // outStr << ' << varSec.name << ";\n"
        end
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        methodString << '    ' << XCTECpp::Utils.getComment(varSec)
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        methodString << varSec.formatText
      end
    end

    methodString << "}\n"

    return methodString
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodGetString.new)
