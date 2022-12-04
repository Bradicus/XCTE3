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
      fakerServiceVar = Utils.instance.createVarFor(cls, "class_angular_datagen_service")
      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)

      bld.startFunction("populateRandom(): void")

      bld.add("this.item = this." + Utils.instance.getStyledVariableName(fakerServiceVar) + ".get()[0];")
      bld.add("this.populate();")

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodRandomPopulate.new)
