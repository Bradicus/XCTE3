#
module XCTETypescript
  class MethodAngularServiceDetail < XCTEPlugin
    def initialize
      @name = "method_angular_service_detail"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, cfg, bld)
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      className = Utils.instance.getStyledClassName(cls.getUName())
      urlName = Utils.instance.getStyledUrlName(cls.getUName())

      bld.startFunction("detail(id: any): Observable<" + className + ">")
      bld.add("return this.httpClient.get<" + className + ">(`${this.apiUrl}/" + urlName + "/${id}`);")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceDetail.new)
