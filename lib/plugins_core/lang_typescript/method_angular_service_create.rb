#
module XCTETypescript
  class MethodAngularServiceCreate < XCTEPlugin
    def initialize
      @name = "method_angular_service_create"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, cfg, bld)
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      className = Utils.instance.getStyledClassName(cls.getUName())
      urlName = Utils.instance.getStyledUrlName(cls.getUName())

      bld.startFunction("create(item: any): any")
      bld.add("return this.httpClient.post<" + className + ">(`${this.apiUrl}/" + urlName + "`, item);")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceCreate.new)
