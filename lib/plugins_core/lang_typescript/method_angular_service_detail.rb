#
module XCTETypescript
  class MethodAngularServiceDetail < XCTEPlugin
    def initialize
      @name = "method_angular_service_detail"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      className = Utils.instance.getStyledClassName(cls.model.name)
      urlName = Utils.instance.getStyledUrlName(cls.model.name)

      bld.startFunction("detail(id: any): Observable<" + className + ">")
      bld.add("return httpClient.get<" + className + ">(`${this.apiURL}/" + urlName + "/${id}`);")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceDetail.new)
