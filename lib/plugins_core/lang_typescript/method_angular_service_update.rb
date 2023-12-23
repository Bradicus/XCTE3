module XCTETypescript
  class MethodAngularServiceUpdate < XCTEPlugin
    def initialize
      @name = 'method_angular_service_update'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld); end

    # Returns the code for the content for this function
    def get_definition(cls, bld, _fun)
      className = Utils.instance.get_styled_class_name(cls.getUName)
      urlName = Utils.instance.getStyledUrlName(cls.getUName)

      bld.startFunction('update(item: any): Observable<' + className + '>')
      bld.add('return this.httpClient.put<' + className + '>(`${this.apiUrl}/' + urlName + '`, item);')
      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodAngularServiceUpdate.new)
