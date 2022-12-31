##
# Class:: ClassTsqlDataStore
#
module XCTEJava
  class ClassTsqlDataStore < ClassBase
    def initialize
      @name = "tsql_data_store"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " data store"
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
      Utils.instance.requires_class_type(cls, "class_jpa_entity")
      cls.addUse("org.springframework.data.jpa.repository.*")

      super
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      idVar = cls.model.getFilteredVars(lambda { |var| var.name == "id" })
      bld.startClass("public interface " + getClassName(cls) + " extends JpaRepository<" +
                     Utils.instance.getStyledClassName(cls.model.name) + ", " +
                     Utils.instance.getObjTypeName(idVar[0]) + ">")

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

XCTEPlugin::registerPlugin(XCTEJava::ClassTsqlDataStore.new)
