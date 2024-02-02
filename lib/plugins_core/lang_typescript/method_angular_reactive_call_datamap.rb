require 'params/utils_each_var_params'

module XCTETypescript
  class MethodPopulateForm < XCTEPlugin
    def initialize
      @name = 'method_angular_reactive_call_datamap'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld, fun)
    end

    # Returns the code for the content for this function
    def render_function(cls, bld, _fun)
      itemVar = CodeNameStyling.getStyled(cls.getUName + ' form', Utils.instance.langProfile.variableNameStyle)
      clsVar = CodeNameStyling.getStyled(cls.getUName + ' form', Utils.instance.langProfile.variableNameStyle)
      populateServiceVar = Utils.instance.create_var_for(cls, 'class_angular_data_map_service')

      return unless !clsVar.nil? && !populateServiceVar.nil?

      bld.start_function('populate(): void')
      bld.add('this.' + Utils.instance.get_styled_variable_name(populateServiceVar) +
              '.populate(this.' + clsVar + ' as FormGroup, this.item);')

      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodPopulateForm.new)
