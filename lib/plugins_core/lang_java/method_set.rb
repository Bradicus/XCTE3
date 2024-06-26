##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a read meathod for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_java/x_c_t_e_java'
require 'plugins_core/lang_java/utils'

module XCTEJava
  class XCTEJava::MethodSet < XCTEPlugin
    def initialize
      @name = 'method_set'
      @language = 'java'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's set method
    def render_function(var, bld)
      return unless var.genGet == true && !var.isPointer

      varName = Utils.instance.get_styled_variable_name(var)
      bld.add('public void ' + Utils.instance.style_as_function('set ' + var.name))
      bld.same_line('(' + Utils.instance.get_type_name(var) + ' ' + varName)
      bld.same_line(")\t{ this." + varName + ' = ' + varName + '; }')
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodSet.new)
