module XCTETypescript
  class MethodAngularServiceDelete < XCTEPlugin
    def initialize
      @name = 'method_angular_service_delete'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld); end

    # Returns the code for the content for this function
    def get_definition(cls, bld, _fun)
      className = Utils.instance.get_styled_class_name(cls.getUName)
      urlName = Utils.instance.getStyledUrlName(cls.getUName)

      bld.startFunction('delete(item: any): any')
      bld.add('return this.httpClient.delete<' + className + '>(`${this.apiUrl}/' + urlName + '/${item.id}`);')
      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodAngularServiceDelete.new)
