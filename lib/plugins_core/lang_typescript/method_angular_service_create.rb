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
      className = Utils.instance.get_styled_class_name(cls.get_u_name)
      urlName = Utils.instance.getStyledUrlName(cls.get_u_name)

      inst_fun = CodeStructure::CodeElemFunction.new(cls)
      inst_fun.add_param(CodeStructure::CodeElemVariable.new(inst_fun).init_as_param("item", 'any'))
      inst_fun.returnValue.vtype = 'Observable<' + className + '>'

      bld.start_function('create', inst_fun)
      bld.add('return this.httpClient.post<' + className + '>(`${this.apiUrl}/' + urlName + '`, item);')
      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodAngularServiceCreate.new)
