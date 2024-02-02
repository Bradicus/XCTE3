module XCTETypescript
  class MethodAngularServiceCreate < XCTEPlugin
    def initialize
      @name = 'method_angular_service_create'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld, fun); end

    # Returns the code for the content for this function
    def render_function(cls, bld, _fun)
      className = Utils.instance.get_styled_class_name(cls.getUName)
      urlName = Utils.instance.getStyledUrlName(cls.getUName)

      bld.start_function('create(item: any): Observable<' + className + '>')
      bld.add('return this.httpClient.post<' + className + '>(`${this.apiUrl}/' + urlName + '`, item);')
      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodAngularServiceCreate.new)
