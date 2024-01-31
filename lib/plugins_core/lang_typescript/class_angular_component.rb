require 'plugins_core/lang_typescript/plugin_base'
require 'plugins_core/lang_typescript/class_standard'
require 'x_c_t_e_plugin'

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class ClassAngularComponent < ClassStandard
    def initialize
      super

      @name = 'class_angular_component'
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(cls.getUName + '.component')
      bld.lfExtension = Utils.instance.get_extension('body')

      render_file_comment(cls, bld)
      bld.separate
      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate
      render_class_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularComponent.new)
