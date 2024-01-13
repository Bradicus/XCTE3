##
# Class:: ClassTsqlDataGen
#
module XCTEJava
  class ClassTsqlDataGen < ClassBase
    def initialize
      super

      @name = 'data_gen'
      @language = 'java'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' data gen'
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererJava.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')

      process_dependencies(cls, bld)

      render_package_start(cls, bld)
      render_dependencies(cls, bld)

      gen_file_comment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      Utils.instance.requires_class_type(cls, cls, 'class_jpa_entity')

      super
    end

    # Returns the code for the comment for this class
    def gen_file_comment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      id_var = cls.model.getFilteredVars(->(var) { var.name == 'id' })

      if id_var.nil?
        Log.error('Missing id var')
      end

      bld.start_class('public class ' + getClassName(cls))

      bld.separate
      # Generate class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(->(var) {}))

      bld.separate

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTEJava::ClassTsqlDataGen.new)
