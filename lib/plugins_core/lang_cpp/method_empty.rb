##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an empty method with the specified function name
# and parameters

require 'code_structure/code_elem_model'
require 'lang_file'

require 'x_c_t_e_plugin'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'

module XCTECpp
  class MethodEmpty < XCTEPlugin
    def initialize
      @name = 'method_empty'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this empty method
    def get_declaration(_cls, bld, fun)
      eDecl = String.new

      eDecl << 'virtual ' if fun.isVirtual

      eDecl << 'static ' if fun.isStatic

      eDecl << 'const ' if fun.returnValue.isConst

      eDecl << Utils.instance.get_type_name(fun.returnValue) << ' '
      eDecl << fun.name << '('

      for param in (0..(fun.parameters.vars.size - 1))
        eDecl << ', ' if param != 0

        eDecl << Utils.instance.get_param_dec(fun.parameters.vars[param])
      end

      eDecl << ')'

      eDecl << ' const' if fun.isConst

      eDecl << ';'

      bld.add(eDecl)
    end

    # Returns definition string for an empty method
    def render_function(cls, bld, fun)
      # Skeleton of comment block
      bld.add('/**')
      bld.add('* ')
      bld.add('* ')

      for param in fun.parameters.vars
        bld.add('* @param ' + Utils.instance.get_styled_variable_name(param))
      end

      if fun.returnValue.vtype != 'void'
        bld.add('*')
        bld.add('* @return ')
      end

      bld.add('*/ ')

      funDec = String.new

      # Function body framework
      funDec << 'const ' if fun.returnValue.isConst

      funDec << Utils.instance.get_type_name(fun.returnValue) + ' '
      funDec << Utils.instance.get_styled_class_name(cls.get_u_name) + ' :: '
      funDec << Utils.instance.get_styled_function_name(fun.name) << '('

      for param in (0..(fun.parameters.vars.size - 1))
        funDec << ', ' if param != 0

        funDec << Utils.instance.get_param_dec(fun.parameters.vars[param])
      end

      funDec << ')'

      funDec << ' const' if fun.isConst

      bld.start_function(funDec)

      bld.add('return();') if fun.returnValue.vtype != 'void'

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodEmpty.new)
