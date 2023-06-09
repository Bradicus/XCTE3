##
# Class:: ClassMapperDozer
#
module XCTEJava
  class ClassMapperDozer < ClassBase
    def initialize
      @name = "class_mapper_dozer"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " mapper"
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
      cls.addUse("org.mapstruct.Mapper")
      cls.addUse("org.mapstruct.MappingTarget")
      cls.addUse("org.mapstruct.factory.Mappers")
      cls.addUse("org.springframework.data.domain.Page")
      super
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      idVar = cls.model.getFilteredVars(lambda { |var| var.name == "id" })

      bld.add "@Mapper"
      bld.startClass("public interface " + getClassName(cls))
      bld.add getClassName(cls) + " INSTANCE = Mappers.getMapper( " + getClassName(cls) + ".class );"
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

XCTEPlugin::registerPlugin(XCTEJava::ClassMapperDozer.new)
