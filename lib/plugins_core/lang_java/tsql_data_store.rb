##
# Class:: ClassRepository
#
module XCTEJava
  class ClassRepository < ClassBase
    def initialize
      @name = "tsql_data_store"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " repository"
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererJava.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      process_dependencies(cls, bld)

      render_package_start(cls, bld)
      render_dependencies(cls, bld)

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      Utils.instance.requires_class_type(cls, "standard")
      cls.addUse("org.springframework.data.repository.*")
      cls.addUse("javax.persistence.*")

      super
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.add("@Entity")
      bld.startClass("public interface " + getClassName(cls) + " extends PagingAndSortingRepository<" +
                     Utils.instance.getStyledClassName(cls.model.name) + ", Long>")

      bld.separate
      # Generate class variables
      eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var| }))

      bld.separate
      # Generate code for functions
      render_functions(cls, bld)

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTEJava::ClassRepository.new)
