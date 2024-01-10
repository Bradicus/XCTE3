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

    def genSourceFiles(cls)
      srcFiles = []

      bld = SourceRendererJava.new
      bld.lfName = Utils.instance.getStyledFileName(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.getExtension('body')

      process_dependencies(cls, bld)

      render_package_start(cls, bld)
      render_dependencies(cls, bld)

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      Utils.instance.requires_class_type(cls, cls, 'class_jpa_entity')

      super
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      id_var = cls.model.getFilteredVars(->(var) { var.name == 'id' })

      if id_var.nil?
        Log.error('Missing id var')
      end

      bld.startClass('public class ' + getClassName(cls))

      bld.separate
      # Generate class variables
      eachVar(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(->(var) {}))

      bld.separate

      # Generate code for functions
      render_functions(cls, bld)

      bld.endClass
    end
  end
end

XCTEPlugin.registerPlugin(XCTEJava::ClassTsqlDataGen.new)
