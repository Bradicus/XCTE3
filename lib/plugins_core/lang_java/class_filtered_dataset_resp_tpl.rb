##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "class_standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_java/utils"
require "plugins_core/lang_java/x_c_t_e_java"

require "code_structure/code_elem_parent"
require "code_structure/code_elem_model"
require "lang_file"

module XCTEJava
  class ClassFilteredDatasetRespTpl < ClassBase
    def initialize
      @name = "class_filtered_resp_tpl"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + " resp tpl"
    end

    def process_dependencies(cls, bld)
      cls.addUse("java.util.List")
      super
    end

    # Returns the code for the header for this class
    def render_body_content(cls, bld)
      headerString = String.new

      bld.separate
      bld.start_class("public class " + get_class_name(cls) + "<T>")

      model = InternalClassModelManager.findModel("page response")

      # Generate class variables
      each_var(uevParams.wCls(model).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.get_var_dec(var))
      }))

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTEJava::ClassFilteredDatasetRespTpl.new)
