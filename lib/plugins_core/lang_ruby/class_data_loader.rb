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

    def genSourceFiles(cls)
      srcFiles = []

      bld = SourceRendererRuby.new
      bld.lfName = Utils.instance.getStyledFileName(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.getExtension('body')

      #      process_dependencies(cls, bld)
      #      render_dependencies(cls, bld)

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld); end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.startClass('class ' + getClassName(cls))

      bld.separate
      # Generate code for class variables
      eachVar(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(->(var) {}))

      bld.separate
      # Generate code for functions
      render_functions(cls, bld)

      bld.endClass
    end
  end
end

XCTEPlugin.registerPlugin(XCTERuby::ClassDataLoader.new)
