module XCTETypescript
  class MethodRandomPopulate < XCTEPlugin
    def initialize
      @name = 'method_service_datagen_random'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, _bld, fun)
      cls.addInclude('@faker-js/faker', 'faker')
    end

    # Returns the code for the content for this function
    def render_function(cls, bld, _fun)
      dataGenUserServiceVar = Utils.instance.create_var_for(cls, 'class_angular_data_gen_service')
      clsVar = CodeNameStyling.getStyled(cls.get_u_name + ' form', Utils.instance.langProfile.variableNameStyle)

      bld.start_function('populateRandom(): void')

      bld.add('this.' + Utils.instance.get_styled_variable_name(dataGenUserServiceVar) + '.populateRandom(this.item);')
      bld.add('this.populate();')

      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodRandomPopulate.new)
