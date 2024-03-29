module XCTETypescript
  class MethodServiceDategenInit < XCTEPlugin
    def initialize
      @name = 'method_service_datagen_init'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, _bld)
      cls.addInclude('@faker-js/faker', 'faker')
    end

    # Returns the code for the content for this function
    def render_function(cls, bld, fun)
      clsVar = CodeNameStyling.getStyled(cls.get_u_name + ' form', Utils.instance.langProfile.variableNameStyle)
      clsName = CodeNameStyling.getStyled(cls.get_u_name + ' form', Utils.instance.langProfile.variableNameStyle)
      clsIntf = Utils.instance.create_var_for(cls, 'standard')

      bld.start_function('initData(item: ' + Utils.instance.get_styled_class_name(cls.model.name) + '): void')

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.isList
          bld.add('item.' + Utils.instance.get_styled_variable_name(var) + ' = [];')
        elsif Utils.instance.is_numeric?(var)
          bld.add('item.' + Utils.instance.get_styled_variable_name(var) + ' = 0;')
        elsif var.getUType.downcase == 'boolean'
          bld.add('item.' + Utils.instance.get_styled_variable_name(var) + ' = false;')
        elsif var.getUType.downcase == 'datetime'
          bld.add('item.' + Utils.instance.get_styled_variable_name(var) + ' = new Date();')
        elsif Utils.instance.is_primitive(var)
          bld.add('item.' + Utils.instance.get_styled_variable_name(var) + " = '';")
        else
          bld.add('item.' + Utils.instance.get_styled_variable_name(var) +
                  ' = new ' + Utils.instance.get_styled_class_name(var.getUType) + '();')
          varCls = ClassModelManager.findVarClass(var, 'standard')
          if !varCls.nil?
            vService = Utils.instance.create_var_for(varCls, 'class_angular_data_gen_service')

            if !vService.nil?
              srcName = 'item.' + Utils.instance.get_styled_variable_name(var)
              bld.add('this.' + Utils.instance.get_styled_variable_name(vService) +
                      '.initData(' + srcName + ');')
            end
          end
        end
      }))

      bld.endFunction
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodServiceDategenInit.new)
