##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an empty method with the specified function name
# and parameters

require 'code_elem_model'
require 'lang_file'

require 'x_c_t_e_plugin'
require 'plugins_core/lang_python/x_c_t_e_python'

module XCTEPython
  class MethodEmpty < XCTEPlugin
    def initialize
      @name = 'method_empty'
      @language = 'python'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for an empty method
    def render_function(_cls, fun, rend)
      indent = String.new('    ')

      # Skeleton of comment block
      rend.add('#')
      rend.add('#')

      for param in fun.parameters.vars
        rend.add('# ' << param.name << '::')
      end

      if fun.returnValue.vtype != 'void'
        rend.add('# ')
        rend.add('# return:: ')
      end

      rend.start_function('def ' + Utils.instance.get_styled_function_name(fun.name))

      # Function body framework

      rend.add('self.' + Utils.instance.get_styled_function_name(fun.name) + '(')

      for param in (0..(fun.parameters.vars.size - 1))
        if param != 0
          rend.same_line(', ')
        end

        rend.same_line(Utils.instance.get_param_dec(fun.parameters.vars[param]))
      end

      rend.same_line(')')
      rend.add

      if fun.returnValue.vtype != 'void'
        rend.add(fun.returnValue.name)
      end

      rend.add('# ' + fun.name)
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEPython::MethodEmpty.new)
