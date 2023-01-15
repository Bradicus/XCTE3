#
module XCTETypescript
  class MethodFakerGet < XCTEPlugin
    def initialize
      @name = "method_service_datagen_faker_get"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@faker-js/faker", "faker")
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld)
      # process class variables

      className = Utils.instance.getStyledClassName(cls.model.name)
      bld.startFunction("populateRandom(item: " + className + "): void")

      genPopulate(cls, bld, "item.")

      bld.endFunction()
    end

    # process variable group
    def genPopulate(cls, bld, name = "")
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        varName = Utils.instance.getStyledVariableName(var)

        if Utils.instance.isPrimitive(var)
          if var.name == "id"
            bld.add("if (" + name + varName + " == undefined)")
            if (Utils.instance.isNumericPrimitive(var))
              bld.iadd(name + varName + " = 0;")
            else
              bld.iadd(name + varName + " = '';")
            end
          elsif !var.isList()
            bld.add(name + varName + " = " + getFakerAssignment(var) + ";")
          else
            bld.add(name + varName + ".push(" + getFakerAssignment(var) + ");")
          end
        elsif (!var.isList())
          varCls = Classes.findVarClass(var, "ts_interface")
          if varCls != nil
            vService = Utils.instance.createVarFor(varCls, "class_angular_data_gen_service")

            if vService != nil
              srcName = "item." + Utils.instance.getStyledVariableName(var)
              bld.add("this." + Utils.instance.getStyledVariableName(vService) +
                      ".populateRandom(" + srcName + ");")
            end
          end
        end
      }))
    end

    def getFakerAssignment(var)
      varType = var.getUType().downcase()

      if Utils.instance.isNumericPrimitive(var)
        return "faker.random.numeric(8)"
      elsif (varType.start_with?("datetime"))
        return "faker.date.recent()"
      elsif (varType.start_with?("boolean"))
        return "faker.datatype.boolean()"
      elsif (var.name.include?("street") && var.name.include?("2"))
        return "faker.address.secondaryAddress()"
      elsif (var.name.include?("street"))
        return "faker.address.street()"
      elsif (var.name.include?("zip"))
        return "faker.address.zipCode()"
      elsif (var.name.include?("state"))
        return "faker.address.stateAbbr()"
      elsif var.name.include? "first name"
        return "faker.name.firstName()"
      elsif var.name.include? "last name"
        return "faker.name.lastName()"
      elsif var.name.include? "city"
        return "faker.address.city()"
      elsif var.name.include? "country"
        return "faker.address.country()"
      elsif var.name.include? "county"
        return "faker.address.county()"
      elsif var.name.include? "email"
        return 'faker.name.firstName() + "." + faker.name.lastName() + "@example.com"'
      end

      return "faker.random.alpha(11)"
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodFakerGet.new)
