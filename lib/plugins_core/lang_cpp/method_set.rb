##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a set meathod for a class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodSet < XCTEPlugin

  def initialize
    @name = "method_set"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's set method
  def get_declaration(codeClass, cfg, codeBuilder)
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE && varSec.genSet == "true"
        if !varSec.isPointer
          if varSec.arrayElemCount == 0
            if XCTECpp::Utils::isPrimitive(varSec)
              codeBuilder.add("        void set" + XCTECpp::Utils::getCapitalizedFirst(varSec.name))
              codeBuilder.sameLine("(" + XCTECpp::Utils::getTypeName(varSec.vtype) + " new" + XCTECpp::Utils::getCapitalizedFirst(varSec.name))
              codeBuilder.sameLine(")\t{ " + varSec.name + " = new" + XCTECpp::Utils::getCapitalizedFirst(varSec.name) + "; };")
            end
          end
        end

      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        codeBuilder.add(XCTECpp::Utils::getComment(varSec))
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        codeBuilder.sameLine(varSec.formatText)
      end
    end
  end

  # Returns definition string for this class's set method
  def get_definition(codeClass, cfg, codeBuilder)
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodSet.new)
