#
module XCTETypescript
  class MethodRandomPopulate < XCTEPlugin
    def initialize
      @name = "method_random_populate"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, cfg, bld)
      cls.addInclude("@faker-js/faker", "faker")
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      # process class variables

      bld.startFunction("populate(): void")

      for group in cls.model.groups
        Utils.instance.genPopulate(cls, bld, group, "this.item.")
      end

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodRandomPopulate.new)
