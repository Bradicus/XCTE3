##
# Class:: ClassDataLoader
#
module XCTERuby
  class ClassDataLoader < ClassBase
    def initialize
      @name = 'class_data_loader'
      @language = 'ruby'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererRuby.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')

      #      process_dependencies(cls, bld)
      #      render_dependencies(cls, bld)

      gen_file_comment(cls, bld)
      gen_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the content for this class
    def gen_body_content(cls, bld)
      bld.start_class('class ' + get_class_name(cls))

      bld.separate
      # Generate code for class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(->(var) {}))

      bld.separate
      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTERuby::ClassDataLoader.new)
