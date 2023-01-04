#
module XCTETypescript
  class MethodAngularServiceListing < XCTEPlugin
    def initialize
      @name = "method_angular_shared_service_listing"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld)
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld, fun)
      className = Utils.instance.getStyledClassName(cls.getUName())
      urlName = Utils.instance.getStyledUrlName(cls.getUName())
      dataServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_store_service")

      bld.startFunction("listing(): Observable<" + className + "[]>")
      bld.startBlock("if (lastUpdate < new Date().addMinutes(-expireMinutes)")
      bld.add('item = ' + Utils.instance.getStyledVariableName(dataServiceVar) + '.listing();')
      bld.endBlock
      bld.separate
      bld.add("return this.item;")
      bld.endFunction() 
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceListing.new)
