#
module XCTETypescript
  class MethodAngularServiceDetail < XCTEPlugin
    def initialize
      @name = "method_angular_service_detail"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld)
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld, fun)
      className = Utils.instance.getStyledClassName(cls.getUName())
      urlName = Utils.instance.getStyledUrlName(cls.getUName())

      bld.startFunction("detail(id: any): Observable<" + className + ">")

      if cls.model.hasVariableType('datetime') || cls.model.hasVariableType('date')
        bld.add "return this.httpClient.get<" + className + ">(`${this.apiUrl}/" + urlName + "/${id}`)"
        bld.indent
        bld.add ".pipe("
        bld.indent
        bld.startBlock 'map((data: ' + className + ')=>'
        for dateVar in cls.model.getFilteredVars(lambda { |var| var.getUType().downcase == 'datetime' || var.getUType().downcase == 'date' })
          bld.add 'data.' + Utils.instance.getStyledVariableName(dateVar) +' = new Date(data.' + Utils.instance.getStyledVariableName(dateVar) + ');'
        end
        bld.add 'return data;'
        bld.endBlock(')')
        bld.unindent
        bld.add ');'
        bld.unindent
      else
        bld.add("return this.httpClient.get<" + className + ">(`${this.apiUrl}/" + urlName + "/${id}`);")
      end

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodAngularServiceDetail.new)
