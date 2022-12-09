#
module XCTETypescript
  class MethodFakerGet < XCTEPlugin
    def initialize
      @name = "method_service_datagen_faker_get"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@faker-js/faker", "faker")
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld)
      # process class variables

      className = Utils.instance.getStyledClassName(cls.model.name)
      bld.startFunction("populateRandom(item: " + className + "): void")

      for group in cls.model.groups
        Utils.instance.genPopulate(cls, bld, group, "item.")
      end

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodFakerGet.new)
