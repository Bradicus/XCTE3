#
module XCTETypescript
  class MethodAngularServiceUpdate < XCTEPlugin
    def initialize
      @name = "method_angular_service_update"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      className = Utils.instance.getStyledClassName(cls.model.name)
      urlName = Utils.instance.getStyledUrlName(cls.model.name)

      bld.startFunction("update(item: " + className + "): any")
      bld.add("return httpClient.put<" + className + ">(`${this.apiURL}/" + urlName + "/${id}`, item);")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceUpdate.new)
