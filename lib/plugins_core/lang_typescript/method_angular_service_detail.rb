module XCTETypescript
  class MethodAngularServiceDetail < XCTEPlugin
    def initialize
      @name = 'method_angular_service_detail'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld, fun); end

    # Returns the code for the content for this function
    def render_function(cls, bld, fun)
      className = Utils.instance.get_styled_class_name(cls.get_u_name)
      urlName = Utils.instance.getStyledUrlName(cls.get_u_name)

      inst_fun = CodeStructure::CodeElemFunction.new(cls)      
      inst_fun.add_param(CodeStructure::CodeElemVariable.new(inst_fun).init_as_param("id", 'any'))
      inst_fun.returnValue.vtype = 'Observable<' + className + '>'

      bld.start_function('detail', inst_fun)

      if cls.model.hasVariableType('datetime') || cls.model.hasVariableType('date')
        bld.add 'return this.httpClient.get<' + className + '>(`${this.apiUrl}/' + urlName + '/${id}`)'
        bld.indent
        bld.add '.pipe('
        bld.indent
        bld.start_block 'map((data: ' + className + ')=>'
        for dateVar in cls.model.getFilteredVars(lambda { |var|
                                                   var.getUType.downcase == 'datetime' || var.getUType.downcase == 'date'
                                                 })
          bld.add 'data.' + Utils.instance.get_styled_variable_name(dateVar) + ' = new Date(data.' + Utils.instance.get_styled_variable_name(dateVar) + ');'
        end
        bld.add 'return data;'
        bld.end_block(')')
        bld.unindent
        bld.add ');'
        bld.unindent
      else
        bld.add('return this.httpClient.get<' + className + '>(`${this.apiUrl}/' + urlName + '/${id}`);')
      end

      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodAngularServiceDetail.new)
