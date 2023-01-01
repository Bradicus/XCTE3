#
module XCTETypescript
  class MethodAngularServiceUpdate < XCTEPlugin
    def initialize
      @name = "method_angular_service_update"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld)
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld, fun)
      className = Utils.instance.getStyledClassName(cls.getUName())
      urlName = Utils.instance.getStyledUrlName(cls.getUName())

      bld.startFunction("update(item: any): any")
      bld.add("return this.httpClient.put<" + className + ">(`${this.apiUrl}/" + urlName + "/${item.id}`, item);")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceUpdate.new)
