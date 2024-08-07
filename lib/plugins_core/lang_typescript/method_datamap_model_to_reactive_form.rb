require "params/utils_each_var_params"

module XCTETypescript
  class MethodPopulateFormService < XCTEPlugin
    def initialize
      @name = "method_datamap_model_to_reactive_form"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, _funItem)
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          Utils.instance.try_add_include_for_var(cls, var, "class_angular_data_map_service")
        end
      }))
    end

    # Returns the code for the content for this function
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      clsVar = CodeNameStyling.getStyled(cls.get_u_name + " form", Utils.instance.langProfile.variableNameStyle)

      inst_fun = CodeStructure::CodeElemFunction.new(cls)
      inst_fun.add_param(CodeStructure::CodeElemVariable.new(inst_fun).init_as_param("formGroup", "FormGroup"))
      inst_fun.add_param(CodeStructure::CodeElemVariable.new(inst_fun).init_as_param("src", Utils.instance.style_as_class(cls.model.name)))

      bld.start_function("populate", inst_fun)

      bld.start_block("if (src != null)")
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if Utils.instance.is_primitive(var)
          vName = Utils.instance.get_styled_variable_name(var)
          # bld.add('formGroup.get("' + vName + '")?.markAsTouched()')
          if var.getUType.downcase == "datetime"
            bld.add('formGroup.get("' + vName + '")?.setValue(src.' + vName + "?.toISOString().slice(0, -1))")
          else
            bld.add('formGroup.get("' + vName + '")?.setValue(src.' + vName + ")")
          end
        elsif !var.hasMultipleItems
          if !var.selectFrom.nil?
            vName = Utils.instance.get_styled_variable_name(var, "", " id")
            # bld.add('formGroup.get("' + vName + '")?.markAsTouched()')
            bld.add('formGroup.get("' + vName + '")?.setValue(src.' + vName + ")")
          else
            varCls = ClassModelManager.findVarClass(var, "class_angular_data_map_service")
            if !varCls.nil?
              vService = Utils.instance.create_var_for(varCls, "class_angular_data_map_service")

              if !vService.nil?
                fgName = "formGroup.get('" + Utils.instance.get_styled_variable_name(var) + "') as FormGroup"
                srcName = "src." + Utils.instance.get_styled_variable_name(var)
                bld.add("this." + Utils.instance.get_styled_variable_name(vService) +
                        ".populate(" + fgName + ", " + srcName + ");")
              end
            end
          end
        end
      }))
      bld.end_block

      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodPopulateFormService.new)
