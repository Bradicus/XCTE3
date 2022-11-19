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
      fakerServiceVar = Utils.instance.createVarFor(cls, "class_angular_faker_service")
      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)

      bld.startFunction("populate(src: " + Utils.instance.getStyledClassName(cls.model.name) + "): void")

      Utils.instance.eachVar(cls, lambda { |var|
        if (Utils.instance.isPrimitive(var))
          vName = Utils.instance.getStyledVariableName(var)
          bld.add("this." + clsVar + '.get("' + vName + '")?.setValue(src.' + vName + ")")
        end
      })

      # bld.add("this.item = this." + Utils.instance.getStyledVariableName(fakerServiceVar) + ".get()[0];")
      # bld.add("this." + clsVar + ".populate(this.item);")

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodPopulateForm.new)
