module XCTETypescript
  class MethodServiceDategenInit < XCTEPlugin
    def initialize
      @name = "method_service_datagen_init"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls)
      cls.addInclude("@faker-js/faker", "faker")
    end

    # Returns the code for the content for this function
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec
      clsVar = CodeNameStyling.getStyled(cls.get_u_name + " form", Utils.instance.langProfile.variableNameStyle)
      clsName = CodeNameStyling.getStyled(cls.get_u_name + " form", Utils.instance.langProfile.variableNameStyle)
      clsIntf = Utils.instance.create_var_for(cls, "class_standard")

      bld.start_function("initData(item: " + Utils.instance.style_as_class(cls.model.name) + ")", fun)

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.isList
          bld.add("item." + Utils.instance.get_styled_variable_name(var) + " = [];")
        elsif Utils.instance.is_numeric?(var)
          bld.add("item." + Utils.instance.get_styled_variable_name(var) + " = 0;")
        elsif var.getUType.downcase == "boolean"
          bld.add("item." + Utils.instance.get_styled_variable_name(var) + " = false;")
        elsif var.getUType.downcase == "datetime"
          bld.add("item." + Utils.instance.get_styled_variable_name(var) + " = new Date();")
        elsif Utils.instance.is_primitive(var)
          bld.add("item." + Utils.instance.get_styled_variable_name(var) + " = '';")
        else
          bld.add("item." + Utils.instance.get_styled_variable_name(var) +
                  " = new " + Utils.instance.style_as_class(var.getUType) + "();")
          varCls = ClassModelManager.findVarClass(var, "class_standard")
          if !varCls.nil?
            vService = Utils.instance.create_var_for(varCls, "class_angular_data_gen_service")

            if !vService.nil?
              srcName = "item." + Utils.instance.get_styled_variable_name(var)
              bld.add("this." + Utils.instance.get_styled_variable_name(vService) +
                      ".initData(" + srcName + ");")
            end
          end
        end
      }))

      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodServiceDategenInit.new)
