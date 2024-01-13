##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a read meathod for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_python/x_c_t_e_python'

class XCTEPython::MethodReadUGP < XCTEPlugin
  def initialize
    @name = 'method_readugp'
    @language = 'python'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's UGP read method
  def get_definition(codeClass, _cfg)
    readDef = String.new

    readDef << "# Reads this object from a stream\n"
    readDef << 'def read' + "(ugsr)\n"
    readDef << "\n"

    if codeClass.has_an_array
      readDef << "    unsigned int i\n\n"
    end

    for par in codeClass.parentsList
      readDef << '    super.read(ugsr)' << "\n"
    end

    varArray = []
    codeClass.getAllVarsFor(varArray)

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE
        if varSec.isStatic # Ignore static variables
          readDef << ''
        elsif !varSec.isPointer
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils.is_primitive(varSec)
              readDef << "\n    for " << varSec.name << 'Item in @' << varSec.name << "\n"
              readDef << '        ugsr.read' << XCTECpp::Utils.getTypeAbbrev(varSec) << '(' << varSec.name << "Item)\n"
              readDef << "      end\n\n"
            else
              readDef << "\n    for " << varSec.name << 'Item in @' << varSec.name << "\n"
              readDef << '        ' + varSec.name << "Item.read(ugsr)\n"
              readDef << "      end\n\n"
            end
          elsif XCTECpp::Utils.is_primitive(varSec) # Not an array
            readDef << '    ugsr.read' << XCTECpp::Utils.getTypeAbbrev(varSec)
            readDef << '(@' + varSec.name << ")\n"
          else
            readDef << '    @' << varSec.name << ".read(ugsr)\n"
          end

        elsif varSec.isPointer
          readDef << '    // ' + varSec.name + " -> read(ugsr);\n"
        else
          readDef << "\n"
        end

      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        readDef << '    ' << XCTECpp::Utils.getComment(varSec)
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        readDef << varSec.formatText
      end
    end

    readDef << "end\n\n"

    return readDef
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEPython::MethodReadUGP.new)
