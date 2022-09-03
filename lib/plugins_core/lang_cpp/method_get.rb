##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a get meathod for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

module XCTECpp
  class MethodGet < XCTEPlugin
    def initialize
      @name = "method_get"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's get method
    def get_declaration(varSec, cfg, codeBuilder)
      if varSec.elementId == CodeElem::ELEM_VARIABLE && varSec.genSet == true
        funName = Utils.instance.getStyledFunctionName("get " + varSec.name)
        varName = Utils.instance.getStyledVariableName(varSec)
        codeBuilder.add("const " + Utils.instance.getTypeName(varSec) + "& " + funName)
        codeBuilder.sameLine("() const\t{ return(" + varName + "); };")
      end
    end

    # This method has no body
    def get_definition(codeClass, cfg, codeBuilder)
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodGet.new)
