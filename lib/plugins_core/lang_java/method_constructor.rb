##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin"
require "plugins_core/lang_java/x_c_t_e_java"
require "plugins_core/lang_java/utils"

module XCTEJava
  class MethodConstructor < XCTEPlugin
    def initialize
      @name = "method_constructor"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, fun)
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec

      bld.add("/**")
      bld.add("* Constructor")
      bld.add("*/")

      bld.start_function(cls.name + "()")

      each_var(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.defaultValue.nil?
          bld.add(Utils.instance.get_styled_variable_name(var) + " = ")

          if var.vtype == "String"
            bld.same_line('"' + var.defaultValue + '";')
          else
            bld.same_line(var.defaultValue + ";")
          end

          if !var.comment.nil?
            bld.same_line("\t// " + var.comment)
          end
        end
      }))

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodConstructor.new)
