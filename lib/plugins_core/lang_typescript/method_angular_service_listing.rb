module XCTETypescript
  class MethodAngularServiceListing < XCTEPlugin
    def initialize
      @name = 'method_angular_service_listing'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, _bld, fun)
      cls.addInclude('shared/paging/filtered-page-req-tpl', 'FilteredPageReqTpl')
      cls.addInclude('shared/paging/filtered-page-resp-tpl', 'FilteredPageRespTpl')
    end

    # Returns the code for the content for this function
    def render_function(cls, bld, _fun)
      className = Utils.instance.get_styled_class_name(cls.get_u_name)
      urlName = Utils.instance.getStyledUrlName(cls.get_u_name)

      inst_fun = CodeStructure::CodeElemFunction.new(cls)
      inst_fun.add_param(CodeStructure::CodeElemVariable.new(inst_fun).init_as_param("req", 'FilteredPageReqTpl<' + className + '>'))
      inst_fun.returnValue.vtype = 'Observable<FilteredPageRespTpl<' + className + '>>'

      bld.start_function('listing', inst_fun)
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
