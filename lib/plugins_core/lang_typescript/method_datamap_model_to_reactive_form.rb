require 'params/utils_each_var_params'

module XCTETypescript
  class MethodPopulateFormService < XCTEPlugin
    def initialize
      @name = 'method_datamap_model_to_reactive_form'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld, _funItem)
      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          Utils.instance.tryAddIncludeForVar(cls, var, 'class_angular_data_map_service')
        end
      }))
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld, _fun)
      clsVar = CodeNameStyling.getStyled(cls.getUName + ' form', Utils.instance.langProfile.variableNameStyle)

      bld.startFunction('populate(formGroup: FormGroup, src: ' + Utils.instance.get_styled_class_name(cls.model.name) + '): void')

      bld.startBlock('if (src != null)')
      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if Utils.instance.is_primitive(var)
          vName = Utils.instance.get_styled_variable_name(var)
          # bld.add('formGroup.get("' + vName + '")?.markAsTouched()')
          if var.getUType.downcase == 'datetime'
            bld.add('formGroup.get("' + vName + '")?.setValue(src.' + vName + '?.toISOString().slice(0, -1))')
          else
            bld.add('formGroup.get("' + vName + '")?.setValue(src.' + vName + ')')
          end
        elsif !var.hasMultipleItems
          if !var.selectFrom.nil?
            vName = Utils.instance.get_styled_variable_name(var, '', ' id')
            # bld.add('formGroup.get("' + vName + '")?.markAsTouched()')
            bld.add('formGroup.get("' + vName + '")?.setValue(src.' + vName + ')')
          else
            varCls = ClassModelManager.findVarClass(var, 'class_angular_data_map_service')
            if !varCls.nil?
              vService = Utils.instance.createVarFor(varCls, 'class_angular_data_map_service')

              if !vService.nil?
                fgName = "formGroup.get('" + Utils.instance.get_styled_variable_name(var) + "') as FormGroup"
                srcName = 'src.' + Utils.instance.get_styled_variable_name(var)
                bld.add('this.' + Utils.instance.get_styled_variable_name(vService) +
                        '.populate(' + fgName + ', ' + srcName + ');')
              end
            end
          end
        end
      }))
      bld.endBlock

      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodPopulateFormService.new)
