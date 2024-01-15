##
# Class:: ClassMapperDozer
#
module XCTEJava
  class ClassMapperDozer < ClassBase
    def initialize
      @name = 'class_mapper_dozer'
      @language = 'java'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' mapper'
    end

    def process_dependencies(cls, bld)
      cls.addUse('org.mapstruct.Mapper')
      cls.addUse('org.mapstruct.MappingTarget')
      cls.addUse('org.mapstruct.factory.Mappers')
      cls.addUse('org.springframework.data.domain.Page')
      super
    end

    # Returns the code for the comment for this class
    def gen_file_comment(cls, bld); end

    # Returns the code for the content for this class
    def gen_body_content(cls, bld)
      idVar = cls.model.getFilteredVars(->(var) { var.name == 'id' })

      bld.add '@Mapper'
      bld.start_class('public interface ' + get_class_name(cls))
      bld.add get_class_name(cls) + ' INSTANCE = Mappers.getMapper( ' + get_class_name(cls) + '.class );'
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

XCTEPlugin.registerPlugin(XCTEJava::ClassMapperDozer.new)
