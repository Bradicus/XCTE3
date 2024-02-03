##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'plugins_core/lang_ruby/utils'
require 'plugins_core/lang_ruby/x_c_t_e_ruby'

module XCTERuby
  class MethodConstructor < XCTEPlugin

    def initialize
      super 
      @name = "method_constructor"
      @language = "ruby"
      @category = XCTEPlugin::CAT_METHOD
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def process_dependencies(cls, bld, fun)
    end

    # Returns the code for the content for this function
    def render_function(cls, bld, fun)
      param_set = []

      for param in fun.parameters.vars
        param_set.push Utils.instance.get_param_dec(param)
      end
      
      for bc in cls.base_classes
        bc_cls_spec = ClassModelManager.findClass(bc.model_name, bc.plugin_name)

        if !bc_cls_spec.nil?
          each_var(uevParams().wCls(bc_cls_spec).wBld(bld).wSeparate(true).wVarCb(lambda { |bc_var|
            for param in fun.parameters.vars
              if param.name == bc_var.name
                varName = Utils.instance.get_styled_variable_name(param)
                bld.add "@" + varName + " = " + varName + ";"
              end
            end
          }))
        end
      end

      bld.start_class("def initialize(" + param_set.join(", ") + ")")

      if cls.base_classes.length > 0
        bld.add 'super'
      end

      each_var(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        for param in fun.parameters.vars
          if var.name == param.name
            varName =  Utils.instance.get_styled_variable_name(var) 
            bld.add '@' + varName + ' = ' + varName
          end
        end
      }))

      bld.end_class
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTERuby::MethodConstructor.new)
