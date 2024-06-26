##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a read meathod for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'

class XCTECpp::MethodReadUGP < XCTEPlugin
  def initialize
    @name = 'method_readugp'
    @language = 'cpp'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's UGP read method
  def render_declaration(_codeClass, _cfg)
    return '        void read' << "(ug::io::StreamReader* ugsr);\n"
  end

  # Returns definition string for this class's UGP read method
  def render_function(codeClass, _cfg)
    readDef = String.new

    readDef << "/**\n* Reads this object from a stream\n*/\n"
    readDef << 'void ' << codeClass.name << ' :: read' + "(ug::io::StreamReader* ugsr)\n"
    readDef << "{\n"

    if codeClass.has_an_array
      readDef << "    unsigned int i;\n\n"
    end

    for par in codeClass.parentsList
      readDef << '    ' << par.name << '::read(ugsr);' << "\n"
    end

    varArray = []
    codeClass.getAllVarsFor(varArray)

    for varSec in varArray
      if varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        if varSec.isStatic # Ignore static variables
          readDef << ''
        elsif !varSec.isPointer
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils.is_primitive(varSec)
              readDef << "\n    for (i = 0; i < " << XCTECpp::Utils.get_size_const(varSec) + "; i++)\n"
              readDef << '        ugsr -> read' << XCTECpp::Utils.getTypeAbbrev(varSec)
              readDef << '(' << varSec.name << "[i]);\n\n"
            else
              readDef << "\n    for (i = 0; i < " << XCTECpp::Utils.get_size_const(varSec) + "; i++)\n"
              readDef << '        ' + varSec.name << "[i].read(ugsr);\n\n"
            end
          elsif XCTECpp::Utils.is_primitive(varSec) # Not an array
            readDef << '    ugsr -> read' << XCTECpp::Utils.getTypeAbbrev(varSec)
            readDef << '(' + varSec.name << ");\n"
          else
            readDef << '    ' << varSec.name << ".read(ugsr);\n"
          end

        elsif varSec.isPointer
          readDef << '    // ' + varSec.name + " -> read(ugsr);\n"
        else
          readDef << "\n"
        end

      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        readDef << '    ' << XCTECpp::Utils.get_comment(varSec)
      elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        readDef << varSec.formatText
      end
    end

    readDef << "}\n\n"

    return readDef
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodReadUGP.new)
