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
      bld.startFunction("get(howMany = 1): Array<" + className + ">")
      bld.add("var items: Array<" + className + "> = new Array<" + className + ">;")

      bld.startBlock("for (var i = 0; i < howMany; i++)")
      for group in cls.model.groups
        bld.add("let item: " + className + " = {} as " + className + ";")
        bld.separate
        Utils.instance.genPopulate(cls, bld, group, "item.")
      end

      bld.add("items.push(item);")
      bld.endBlock
      bld.separate
      bld.add("return items;")

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodFakerGet.new)
