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
      cls.addInclude("@faker-js/faker", "faker")
    end

    # Returns the code for the content for this function
    def get_definition(cls, cfg, bld)
      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)

      bld.startFunction("populate(formGroup: FormGroup, src: " + Utils.instance.getStyledClassName(cls.model.name) + "): void")

      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
        if (Utils.instance.isPrimitive(var))
          vName = Utils.instance.getStyledVariableName(var)
          bld.add('formGroup.get("' + vName + '")?.setValue(src.' + vName + ")")
        else
          varCls = Classes.findVarClass(var)
          if varCls != nil
            vService = Utils.instance.createVarFor(varCls, "method_populate_reactive_form")

            if vService != nil
              bld.add("formGroup." + Utils.instance.getStyledVariableName(var) +
                      " = this." + Utils.instance.getStyledVariableName(vService) + ".populate();")
            end
          end
        end
      }))

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodPopulateForm.new)
