##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_typescript/x_c_t_e_typescript.rb'
require 'plugins_core/lang_typescript/utils'

module XCTETypescript
  class MethodConstructor < XCTEPlugin

    def initialize
      super

      @name = "method_constructor"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def get_unformatted_fun_name(cls, fun)
      return 'constructor'
    end

    def process_dependencies(cls, bld, fun); end

    # Returns the code for the content for this function
    def render_function(cls, bld, fun)
      params = []

      for param in fun.parameters.vars
        params.push Utils.instance.get_param_dec(param)
      end

      bld.start_function_paramed(get_unformatted_fun_name(cls, fun), params)

      if cls.base_classes.length > 0
        bc = cls.base_classes[0]
        bc_cls_spec = ClassModelManager.findClass(bc.model_name, bc.plugin_name)
        base_constructor_fun = bc_cls_spec.get_function('method_constructor')
        if !base_constructor_fun.nil?
          b_params = []

          for param in base_constructor_fun.parameters.vars
            b_params.push Utils.instance.get_styled_variable_name(param)
          end

          bld.add 'super(' + b_params.join(', ') + ');'
        else
          bld.add 'super();'
        end
      end

      for bc in cls.base_classes
        bc_cls_spec = ClassModelManager.findClass(bc.model_name, bc.plugin_name)

        if !bc_cls_spec.nil?
          each_var(uevParams().wCls(bc_cls_spec).wBld(bld).wSeparate(true).wVarCb(lambda { |bc_var|
            for param in fun.parameters.vars
              if param.name == bc_var.name
                varName = Utils.instance.get_styled_variable_name(param)
                bld.add "this." + varName + " = " + varName + ";"
              end
            end
          }))
        end
      end

      each_var(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        for param in fun.parameters.vars
          if param.name == var.name
            varName = Utils.instance.get_styled_variable_name(param)
            bld.add "this." + varName + " = " + varName + ";"
          end
        end
      }))

      bld.end_class
    end

  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTETypescript::MethodConstructor.new)
