#
module XCTETypescript
  class MethodAngularSharedServiceListing < XCTEPlugin
    def initialize
      @name = "method_angular_shared_service_listing"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld)
      cls.addInclude("shared/class/filtered-page-tpl", "FilteredPageTpl")
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld, fun)
      className = Utils.instance.getStyledClassName(cls.getUName())
      urlName = Utils.instance.getStyledUrlName(cls.getUName())
      dataServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_store_service")

      bld.startFunction("listing(): Observable<FilteredPageTpl<" + className + ">>")
      bld.startBlock("if ((this.lastUpdate + this.expireMinutes * 60000) < new Date())")
      bld.add("this.item = " + Utils.instance.getStyledVariableName(dataServiceVar) + ".listing();")
      bld.endBlock
      bld.separate
      bld.add("return this.item;")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularSharedServiceListing.new)
