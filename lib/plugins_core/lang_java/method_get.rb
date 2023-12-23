##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a get meathod for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_java/utils'
require 'plugins_core/lang_java/x_c_t_e_java'

module XCTEJava
  class MethodGet < XCTEPlugin
    def initialize
      @name = 'method_get'
      @language = 'java'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's get method
    def get_definition(var, bld)
      return unless var.genGet == true && !var.isPointer

      varName = Utils.instance.get_styled_variable_name(var)
      bld.add('public ' + Utils.instance.getTypeName(var) + ' ' + Utils.instance.getStyledFunctionName('get ' + var.name))
      bld.sameLine("()\t{ return(" + varName + '); }')
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodGet.new)
