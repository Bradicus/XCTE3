#
module XCTETypescript
  class MethodAngularServiceUpdate < XCTEPlugin
    def initialize
      @name = "method_angular_service_update"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def get_dependencies(cls, cfg, bld)
      fPath = Utils.instance.getStyledFileName(var.utype)
      cls.addInclude("shared/interfaces/" + fPath + ".ts")
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      className = Utils.instance.getStyledClassName(cls.getUName())
      urlName = Utils.instance.getStyledUrlName(cls.getUName())

      bld.startFunction("update(item: " + className + "): any")
      bld.add("return httpClient.put<" + className + ">(`${this.apiURL}/" + urlName + "/${id}`, item);")
      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceUpdate.new)
