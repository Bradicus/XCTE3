#
module XCTETypescript
  class MethodAngularServiceCreate < XCTEPlugin
    def initialize
      @name = "method_angular_service_create"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      className = Utils.instance.getStyledClassName(cls.getUName())
      urlName = Utils.instance.getStyledUrlName(cls.getUName())

      bld.startFunction("create(item: " + className + "): any")
      bld.add("return httpClient.post<" + className + ">(`${this.apiURL}/" + urlName + "`, item);")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceCreate.new)
