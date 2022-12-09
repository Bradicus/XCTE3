#
module XCTETypescript
  class MethodRandomPopulate < XCTEPlugin
    def initialize
      @name = "method_service_datagen_random"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@faker-js/faker", "faker")
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld)
      dataGenUserServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_gen_service")
      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)

      bld.startFunction("populateRandom(): void")

      bld.add("this." + Utils.instance.getStyledVariableName(dataGenUserServiceVar) + ".populateRandom(this.item);")
      bld.add("this.populate();")

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodRandomPopulate.new)
