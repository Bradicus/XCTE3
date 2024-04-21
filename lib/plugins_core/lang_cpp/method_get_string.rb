##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a method that returns the class variables as a string
# this class to a stream

require "plugins_core/lang_cpp/x_c_t_e_cpp"

class XCTECpp::MethodGetString < XCTEPlugin
  def initialize
    @name = "method_get_string"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's logIt method
  def render_declaration(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec

    bld.add "\n#ifdef _LOG_IT\n"
    bld.add "        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const;\n"
    bld.add "#else\n"
    bld.add "        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const{;};\n"
    bld.add "#endif\n"
  end

  # Returns definition string for this class's logIt method
  def render_function(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec

    bld.add "/**\n* Returns a string representing object data\n"
    bld.add "*/\n"

    bld.add "std::string " << cls.name << " :: getString() const\n"
    bld.add "{\n"

    if cls.has_an_array
      bld.add "    unsigned int i;\n\n"
    end

    bld.add "    std::stringstream outStr;\n\n"

    varArray = []
    cls.getAllVarsFor(varArray)

    for varSec in varArray
      if varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        if !varSec.isPointer
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils.is_primitive(varSec)
              bld.add '    outStr << "' << varSec.name << ': {";'
              bld.add "\n    for (i = 0; i < " << XCTECpp::Utils.get_size_const(varSec) << "; i++)\n"
              bld.add "        outStr << "
              bld.add varSec.name << "[i] << \"  \";\n"
              bld.add "    outStr << \"}\"\n\n"
            else
              bld.add '    outStr << indent << "' << varSec.name << ': [";'

              bld.add "        for (i = 0; i < " << XCTECpp::Utils.get_size_const(varSec) + "; i++)\n"
              bld.add "            " << varSec.name << "[i].logIt(outStr,  indent + \"  \");\n\n"
              bld.add "        outStr << \" ] \";\n\n"
            end
          elsif XCTECpp::Utils.is_primitive(varSec) # Not an array
            bld.add '    outStr << "' << varSec.name << ': " << '
            bld.add varSec.name + " << \"  \";\n"
          else
            bld.add '    outStr << "Object ' << varSec.name << ': ";'
            bld.add "        " << varSec.name << ".getString();\n"
          end
        else
          bld.add "    // outStr << " << varSec.name << ";\n"
        end
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        bld.add "    " << XCTECpp::Utils.get_comment(varSec)
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        bld.add varSec.formatText
      end
    end

    bld.add "}\n"
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodGetString.new)
