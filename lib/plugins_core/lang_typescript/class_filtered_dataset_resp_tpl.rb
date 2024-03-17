##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_typescript/utils"
require "plugins_core/lang_typescript/x_c_t_e_typescript"

require "code_structure/code_elem_parent"
require "code_structure/code_elem_model"
require "lang_file"

module XCTETypescript
  class ClassFilteredDatasetRespTpl < ClassBase
    def initialize
      @name = "class_filtered_resp_tpl"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + " resp tpl"
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension("body")

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)
      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the header for this class
    def render_body_content(cls, bld)
      headerString = String.new

      bld.separate

      for inc in cls.includes
        bld.add("require '" + inc.path + inc.name + "." + Utils.instance.get_extension("body") + "'")
      end

      bld.separate
      bld.start_class("export class " + get_class_name(cls) + "<T>")

      model = InternalClassModelManager.findModel("page response")

      # Generate class variables
      each_var(uevParams.wCls(model).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.get_var_dec(var))
      }))

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassFilteredDatasetRespTpl.new)
