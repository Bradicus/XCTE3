##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a write meathod for a class

require 'plugins_core/lang_cpp/x_c_t_e_cpp'

class XCTECpp::MethodWriteUGP < XCTEPlugin
  def initialize
    @name = 'method_writeugp'
    @language = 'cpp'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's UGP write method
  def render_declaration(_codeClass, _cfg)
    return '        void write' << "(ug::io::StreamWriter* ugsw);\n"
  end

  # Returns definition string for this class's UGP write method
  def render_function(codeClass, _cfg)
    writeDef = String.new

    writeDef << "/**\n* Writes this object from a stream\n*/\n"
    writeDef << 'void ' << codeClass.name << ' :: write' + "(ug::io::StreamWriter* ugsw)\n"
    writeDef << "{\n"

    if codeClass.has_an_array
      writeDef << "    unsigned int i;\n\n"
    end

    for par in codeClass.parentsList
      writeDef << '    ' << par.name << '::write(ugsw);' << "\n"
    end

    varArray = []
    codeClass.getAllVarsFor(varArray)

    for varSec in varArray
      if varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        if varSec.isStatic # Ignore static variables
          writeDef << ''
        elsif !varSec.isPointer
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils.is_primitive(varSec)
              writeDef << "\n    for (i = 0; i < " << XCTECpp::Utils.get_size_const(varSec) + "; i++)\n"
              writeDef << '        ugsw -> write' << XCTECpp::Utils.getTypeAbbrev(varSec)
              writeDef << '(' << varSec.name << "[i]);\n\n"
            else
              writeDef << "\n    for (i = 0; i < " << XCTECpp::Utils.get_size_const(varSec) + "; i++)\n"
              writeDef << '        ' + varSec.name << "[i].write(ugsw);\n\n"
            end
          elsif XCTECpp::Utils.is_primitive(varSec) # Not an array
            writeDef << '    ugsw -> write' << XCTECpp::Utils.getTypeAbbrev(varSec)
            writeDef << '(' + varSec.name << ");\n"
          else
            writeDef << '    ' << varSec.name << ".write(ugsw);\n"
          end

        elsif varSec.isPointer
          writeDef << '    // ' + varSec.name + " -> write(ugsw);\n"
        else
          writeDef << "\n"
        end

      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        writeDef << '    ' << XCTECpp::Utils.get_comment(varSec)
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        writeDef << varSec.formatText
      end
    end

    writeDef << "}\n\n"

    return writeDef
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodWriteUGP.new)
