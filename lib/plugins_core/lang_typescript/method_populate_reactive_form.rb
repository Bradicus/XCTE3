require "utils_each_var_params.rb"

#
module XCTETypescript
  class MethodPopulateForm < XCTEPlugin
    def initialize
      @name = "method_populate_reactive_form"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, cfg, bld)
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      itemVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      populateServiceVar = Utils.instance.createVarFor(cls, "class_angular_reactive_populate_service")

      bld.startFunction("populate(): void")
      bld.add("this." + Utils.instance.getStyledVariableName(populateServiceVar) +
              ".populate(this." + clsVar + " as FormGroup, this.item);")

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodPopulateForm.new)
