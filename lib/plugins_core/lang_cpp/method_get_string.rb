##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a method that returns the class variables as a string
# this class to a stream

require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodGetString < XCTEPlugin

  def initialize
    @name = "method_get_string"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's logIt method
  def get_declaration(codeClass, cfg)
    methodString = String.new

    methodString << "\n#ifdef _LOG_IT\n"
    methodString << "        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const;\n"
    methodString << "#else\n"
    methodString << "        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const{;};\n"
    methodString << "#endif\n"

    return methodString
  end

  # Returns definition string for this class's logIt method
  def get_definition(codeClass, cfg)
    methodString = String.new

    methodString << "/**\n* Returns a string representing object data\n"
    methodString << "*/\n";

    methodString << "std::string " << codeClass.name << " :: getString() const\n"
    methodString << "{\n"

    if codeClass.hasAnArray
      methodString << "    unsigned int i;\n\n"
    end

    methodString << "    std::stringstream outStr;\n\n"

    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE
        if !varSec.isPointer
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils::isPrimitive(varSec)
              methodString << "    outStr << \"" << varSec.name << ": {\";"
              methodString << "\n    for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) << "; i++)\n"
              methodString << "        outStr << "
              methodString << varSec.name << "[i] << \"  \";\n"
              methodString << "    outStr << \"}\"\n\n"
            else
              methodString << "    outStr << indent << \"" << varSec.name << ": [\";"

              methodString << "        for (i = 0; i < " << XCTECpp::Utils::getSizeConst(varSec) + "; i++)\n"
              methodString << "            " << varSec.name << "[i].logIt(outStr,  indent + \"  \");\n\n"
              methodString << "        outStr << \" ] \";\n\n"
            end
          else  # Not an array
            if XCTECpp::Utils::isPrimitive(varSec)
              methodString << "    outStr << \"" << varSec.name << ": \" << "
              methodString << varSec.name +  " << \"  \";\n"
            else
              methodString << "    outStr << \"Object " << varSec.name << ": \";"
              methodString << "        " << varSec.name << ".getString();\n"
            end
          end
        else
          methodString << "    // outStr << " << varSec.name << ";\n"
        end
      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        methodString << "    " << XCTECpp::Utils::getComment(varSec);
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        methodString << varSec.formatText
      end
    end

    methodString << "}\n"

    return methodString
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodGetString.new)
