##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a get meathod for a class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodGet < XCTEPlugin

  def initialize
    @name = "method_get"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end

  # Returns declairation string for this class's get method
  def get_declaration(codeClass, cfg, codeGen)
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE && varSec.genGet == "true"
        if !varSec.isPointer
          if varSec.arrayElemCount == 0
            if XCTECpp::Utils::isPrimitive(varSec)
              codeGen.add("const " + XCTECpp::Utils::getTypeName(varSec.vtype) + "& get" + XCTECpp::Utils::getCapitalizedFirst(varSec.name))
              codeGen.sameLine("() const\t{ return(" + varSec.name + "); };")
            end
          end
        end

      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        codeGen.add(XCTECpp::Utils::getComment(varSec))
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        codeGen.add(varSec.formatText)
      end
    end
  end

  # This method has no body
  def get_definition(codeClass, cfg, codeGen)
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodGet.new)
