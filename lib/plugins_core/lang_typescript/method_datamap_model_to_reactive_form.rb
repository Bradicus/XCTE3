require "params/utils_each_var_params.rb"

#
module XCTETypescript
  class MethodPopulateFormService < XCTEPlugin
    def initialize
      @name = "method_datamap_model_to_reactive_form"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld, funItem)
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
        if (!Utils.instance.isPrimitive(var) && !var.hasMultipleItems())
          plug = XCTEPlugin::findClassPlugin("typescript", "class_angular_datamap_service")
          varCls = Classes.findVarClass(var)
          if varCls != nil
            varModelCls = varCls.model.findClassByType("class_angular_datamap_service")
            #vService = Utils.instance.createVarFor(varCls, "class_angular_datamap_service")
            incPath = plug.getFilePath(varModelCls)
            incCls = plug.getClassName(varCls)
            cls.addInclude(incPath, incCls)
          end
        end
      }))
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld, fun)
      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)

      bld.startFunction("populate(formGroup: FormGroup, src: " + Utils.instance.getStyledClassName(cls.model.name) + "): void")

      bld.startBlock("if (src != null)")
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
        if (Utils.instance.isPrimitive(var))
          vName = Utils.instance.getStyledVariableName(var)
          bld.add('formGroup.get("' + vName + '")?.setValue(src.' + vName + ")")
        elsif (!Utils.instance.isPrimitive(var) && !var.hasMultipleItems())
          varCls = Classes.findVarClass(var)
          if varCls != nil
            vService = Utils.instance.createVarFor(varCls, "class_angular_datamap_service")

            if vService != nil
              fgName = "formGroup.get('" + Utils.instance.getStyledVariableName(var) + "') as FormGroup"
              srcName = "src." + Utils.instance.getStyledVariableName(var)
              bld.add("this." + Utils.instance.getStyledVariableName(vService) +
                      ".populate(" + fgName + ", " + srcName + ");")
            end
          end
        end
      }))
      bld.endBlock

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodPopulateFormService.new)
