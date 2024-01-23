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
      @name = "method_constructor"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld, fun); end

    # Returns the code for the content for this function
    def get_definition(cls, bld, fun)
      param_str = ''

      for param in fun.parameters.vars
        param_str += Utils.instance.get_param_dec(param)
      end

      bld.start_class("constructor(" + param_str + ")")

      if cls.baseClasses.length > 0
        bld.add 'super();'
      end

      for bc in cls.baseClasses
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
      }))

      bld.end_class
    end

  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTETypescript::MethodConstructor.new)
