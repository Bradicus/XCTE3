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
      fakerServiceVar = Utils.instance.createVarFor(cls, "class_angular_faker_service")

      bld.startFunction("populate(): void")

      bld.add("this.item = this." + Utils.instance.getStyledVariableName(fakerServiceVar) + ".get()[0];")
      bld.add("this.userForm.patchValue(this.item);")

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodRandomPopulate.new)
