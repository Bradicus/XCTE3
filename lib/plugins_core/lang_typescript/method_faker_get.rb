#
module XCTETypescript
  class MethodRandomPopulate < XCTEPlugin
    def initialize
      @name = "method_faker_get"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, cfg, bld)
      cls.addInclude("@faker-js/faker", "faker")
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      # process class variables

      className = Utils.instance.getStyledClassName(cls.model.name)
      bld.startFunction("get(howMany = 1): " + className + "[]")
      bld.add("items: " + className + "[] = [];")

      bld.startBlock("for (i = 0; i < howMany; i++)")
      for group in cls.model.groups
        bld.add("let nextItem: User = {} as User;")
        bld.separate
        Utils.instance.genPopulate(cls, bld, group, "item.")
      end

      bld.add("items.push(item);")
      bld.endBlock

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodRandomPopulate.new)
