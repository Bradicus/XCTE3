#
module XCTETypescript
  class MethodAngularServiceListing < XCTEPlugin
    def initialize
      @name = "method_angular_service_listing"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld)
      cls.addInclude("shared/paging/filtered-page-req-tpl", "FilteredPageReqTpl")
      cls.addInclude("shared/paging/filtered-page-resp-tpl", "FilteredPageRespTpl")
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld, fun)
      className = Utils.instance.getStyledClassName(cls.getUName())
      urlName = Utils.instance.getStyledUrlName(cls.getUName())

      bld.startFunction("listing(req: FilteredPageReqTpl<" + className + ">): Observable<FilteredPageRespTpl<" + className + ">>")
      bld.add("return this.httpClient.get<FilteredPageRespTpl<" + className + ">>(`${this.apiUrl}/" + urlName + "`);")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceListing.new)
