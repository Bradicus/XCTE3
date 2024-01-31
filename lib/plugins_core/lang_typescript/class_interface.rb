require 'plugins_core/lang_typescript/class_base'

##
# Class:: ClassInterface
#
module XCTETypescript
  class ClassInterface < ClassBase
    def initialize
      @name = 'ts_interface'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')
      process_dependencies(cls, bld)
      render_dependencies(cls, bld)
      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      super

      # Generate class variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        Utils.instance.try_add_include_for_var(cls, var, 'standard') if !Utils.instance.is_primitive(var)
      }))
    end

    def render_file_comment(cls, bld); end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      bld.separate
      bld.start_block('export interface ' + get_class_name(cls))

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.getVarDec(var))
      }))

      bld.end_block
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassInterface.new)
