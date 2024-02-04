##
# Class:: ClassTsqlDataGen
#
module XCTECSharp
  class ClassTsqlDataGen < ClassBase
    def initialize
      super

      @name = 'data_gen'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + ' data gen'
    end

    def process_dependencies(cls, bld)
      super

      Utils.instance.requires_other_class_type(cls, 'class_db_entity')
    end

    # Returns the code for the comment for this class
    def render_file_comment(cls, bld)
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      id_var = cls.model.getFilteredVars(->(var) { var.name == 'id' })

      if id_var.nil?
        Log.error('Missing id var')
      end

      bld.start_class('public class ' + get_class_name(cls))

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

XCTEPlugin.registerPlugin(XCTECSharp::ClassTsqlDataGen.new)
