module XCTETypescript
  class MethodAngularSharedServiceListing < XCTEPlugin
    def initialize
      @name = 'method_angular_shared_service_listing'
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
      dataServiceVar = Utils.instance.createVarFor(cls, 'class_angular_data_store_service')

      bld.startFunction('listing(req: FilteredPageReqTpl<' + className + '>): Observable<FilteredPageRespTpl<' + className + '>>')
      bld.startBlock('if ((this.lastUpdate + this.expireMinutes * 60000) < new Date())')
      bld.add('this.item = ' + Utils.instance.get_styled_variable_name(dataServiceVar) + '.listing(req);')
      bld.endBlock
      bld.separate
      bld.add('return this.item;')
      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodAngularSharedServiceListing.new)
