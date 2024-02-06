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
      classDec = cls.model.visibility + ' class ' + get_class_name(cls)

      for par in (0..cls.base_classes.size)
        if par == 0 && !cls.base_classes[par].nil?
          classDec << ' : ' << cls.base_classes[par].visibility << ' ' << cls.base_classes[par].name
        elsif !cls.base_classes[par].nil?
          classDec << ', ' << cls.base_classes[par].visibility << ' ' << cls.base_classes[par].name
        end
      end

      bld.start_class(classDec)

      # Process variables
      each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        XCTECSharp::Utils.instance.get_var_dec(var)
      }))

      bld.add if cls.functions.length > 0

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassTsqlDataGen.new)
