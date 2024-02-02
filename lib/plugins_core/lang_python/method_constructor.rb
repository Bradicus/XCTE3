##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_python/x_c_t_e_python'

module XCTEPython
  class MethodConstructor < XCTEPlugin
    def initialize
      @name = 'method_constructor'
      @language = 'python'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(cls, _fun, rend)
      conDef = String.new

      rend.add('# Initializer')

      rend.start_function('def __init__(self)')

      varArray = []
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.isStatic != true
          if !var.defaultValue.nil?
            rend.add('self.' << Utils.instance.get_styled_variable_name(var) + ' = ')

            if var.vtype == 'String'
              rend.same_line('"' + var.defaultValue + '"')
            else
              rend.same_line(var.defaultValue)
            end

            if !var.comment.nil?
              rend.same_line("\t# " + var.comment)
            end

            rend.add
          else
            rend.add('self.' << Utils.instance.get_styled_variable_name(var) + ' = None')
          end
        end
      end

      rend.end_block('# init')
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEPython::MethodConstructor.new)
