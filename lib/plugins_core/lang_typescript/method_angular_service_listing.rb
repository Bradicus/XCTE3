module XCTETypescript
  class MethodAngularServiceListing < XCTEPlugin
    def initialize
      @name = 'method_angular_service_listing'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, _bld)
      cls.addInclude('shared/paging/filtered-page-req-tpl', 'FilteredPageReqTpl')
      cls.addInclude('shared/paging/filtered-page-resp-tpl', 'FilteredPageRespTpl')
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld, _fun)
      className = Utils.instance.get_styled_class_name(cls.getUName)
      urlName = Utils.instance.getStyledUrlName(cls.getUName)

      bld.startFunction('listing(req: FilteredPageReqTpl<' + className + '>): Observable<FilteredPageRespTpl<' + className + '>>')
      bld.add 'let params = new HttpParams();'
      bld.separate
      bld.add 'params = params.append("pageNum", req.pageNum);'
      bld.add 'params = params.append("pageSize", req.pageSize);'
      bld.add 'params = params.append("sortBy", req.sortBy);'
      bld.add 'params = params.append("sortAsc", req.sortAsc);'
      bld.add 'params = params.append("searchValue", req.searchValue);'
      bld.separate
      bld.add('return this.httpClient.get<FilteredPageRespTpl<' + className + '>>(`${this.apiUrl}/' + urlName + '`, { params} );')
      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodAngularServiceListing.new)
