#
module XCTETypescript
  class MethodAngularServiceListing < XCTEPlugin
    def initialize
      @name = "method_angular_service_listing"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      className = Utils.instance.getStyledClassName(cls.model.name)
      urlName = Utils.instance.getStyledUrlName(cls.model.name)

      bld.startFunction("listing(): Observable<" + className + ">")
      bld.add("return httpClient.get<" + className + "[]>(`${this.apiURL}/" + urlName + "`);")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceListing.new)
