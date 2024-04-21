module XCTETypescript
  class MethodAngularServiceDelete < XCTEPlugin
    def initialize
      @name = "method_angular_service_delete"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld, fun); end

    # Returns the code for the content for this function
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      className = Utils.instance.style_as_class(cls.get_u_name)
      urlName = Utils.instance.get_styled_url_name(cls.get_u_name)

      inst_fun = CodeStructure::CodeElemFunction.new(cls)
      inst_fun.add_param(CodeStructure::CodeElemVariable.new(inst_fun).init_as_param("item", "any"))
      inst_fun.returnValue.vtype = "any"

      bld.start_function("delete", inst_fun)
      bld.add("return this.httpClient.delete<" + className + ">(`${this.apiUrl}/" + urlName + "/${item.id}`);")
      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodAngularServiceDelete.new)
