module XCTETypescript
  class MethodAngularSharedServiceListing < XCTEPlugin
    def initialize
      @name = 'method_angular_shared_service_listing'
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
      dataServiceVar = Utils.instance.create_var_for(cls, 'class_angular_data_store_service')

      bld.start_function('listing(req: FilteredPageReqTpl<' + className + '>): Observable<FilteredPageRespTpl<' + className + '>>')
      bld.start_block('if ((this.lastUpdate + this.expireMinutes * 60000) < new Date())')
      bld.add('this.item = ' + Utils.instance.get_styled_variable_name(dataServiceVar) + '.listing(req);')
      bld.end_block
      bld.separate
      bld.add('return this.item;')
      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodAngularSharedServiceListing.new)
