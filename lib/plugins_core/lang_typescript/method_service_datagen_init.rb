#
module XCTETypescript
  class MethodServiceDategenInit < XCTEPlugin
    def initialize
      @name = "method_service_datagen_init"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@faker-js/faker", "faker")
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld)
      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      clsName = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      clsIntf = Utils.instance.createVarFor(cls, "class_interface")

      bld.startFunction("initData(item: " + Utils.instance.getStyledClassName(cls.model.name) + "): void")

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.hasMultipleItems()
          bld.add("item." + Utils.instance.getStyledVariableName(var) + " = [];")
        else
          if Utils.instance.isNumericPrimitive(var)
            bld.add("item." + Utils.instance.getStyledVariableName(var) + " = 0;")
          elsif var.getUType().downcase == 'boolean'
              bld.add("item." + Utils.instance.getStyledVariableName(var) + " = false;")
          elsif var.getUType().downcase == "datetime"
            bld.add("item." + Utils.instance.getStyledVariableName(var) + " = new Date();")
          elsif Utils.instance.isPrimitive(var)
            bld.add("item." + Utils.instance.getStyledVariableName(var) + " = '';")
          else
            bld.add("item." + Utils.instance.getStyledVariableName(var) +
                    " = {} as " + Utils.instance.getStyledClassName(var.getUType()) + ";")
            varCls = Classes.findVarClass(var, "ts_interface")
            if varCls != nil
              vService = Utils.instance.createVarFor(varCls, "class_angular_data_gen_service")
  
              if vService != nil
                srcName = "item." + Utils.instance.getStyledVariableName(var)
                bld.add("this." + Utils.instance.getStyledVariableName(vService) +
                        ".initData(" + srcName + ");")
              end
            end
          end
        end        
      }))

      bld.endFunction()
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodServiceDategenInit.new)
