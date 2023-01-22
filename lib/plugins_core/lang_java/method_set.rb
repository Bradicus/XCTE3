##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a read meathod for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_java/x_c_t_e_java.rb"
require "plugins_core/lang_java/utils.rb"

module XCTEJava
  class XCTEJava::MethodSet < XCTEPlugin
    def initialize
      @name = "method_set"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's set method
    def get_definition(var, bld)
      if var.genGet == true && !var.isPointer && var.storeIn == nil
        varName = Utils.instance.getStyledVariableName(var)
        bld.add("public void " + Utils.instance.getStyledFunctionName("set " + var.name))
        bld.sameLine("(" + Utils.instance.getTypeName(var) + " " + varName)
        bld.sameLine(")\t{ this." + varName + " = " + varName + "; }")
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodSet.new)
