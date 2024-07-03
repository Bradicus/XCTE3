module XCTECSharp
  class MethodFakerGet < XCTEPlugin
    def initialize
      super

      @name = "method_service_datagen_faker_get"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns the code for the content for this function
    def render_function(cls, bld, _fun)
      # process class variables

      className = Utils.instance.style_as_class(cls.model.name)
      bld.start_function("void populateRandom(Faker faker, " + className + " item)")

      genPopulate(cls, bld, "item.")

      bld.endFunction
    end

    def process_dependencies(cls, _fun)
      cls.addUse("Bogus")
    end

    # process variable group
    def genPopulate(cls, bld, name = "")
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        varName = Utils.instance.get_styled_variable_name(var)

        if Utils.instance.is_primitive(var)
          if var.name == "id"
          elsif !var.isList
            bld.add(name + varName + " = " + getFakerAssignment(var) + ";")
          else
            bld.add(name + varName + ".push(" + getFakerAssignment(var) + ");")
          end
          # elsif !var.isList
          #   varCls = ClassModelManager.findVarClass(var, 'data_gen')
          #   if !varCls.nil?
          #     vService = Utils.instance.create_var_for(varCls, 'class_angular_data_gen_service')

          #     if !vService.nil?
          #       srcName = 'item.' + Utils.instance.get_styled_variable_name(var)
          #       bld.add('this.' + Utils.instance.get_styled_variable_name(vService) +
          #               '.populateRandom(' + srcName + ');')
          #     end
          #   end
        end
      }))
    end

    def getFakerAssignment(var)
      varType = var.getUType.downcase

      if !var.selectFrom.nil?
        return "1"
      elsif var.name.include?("amount") || var.name.include?("price")
        return "faker.Price()"
      elsif Utils.instance.is_numeric?(var)
        return "faker.Random.Number(1, 8)"
      elsif varType.start_with?("datetime")
        return "LocalDateTime.ofInstant(faker.Date.Past())"
      elsif varType.start_with?("boolean")
        return "faker.Random.Bool()"
      elsif var.name.include?("username")
        return "faker.Internet.UserName()"
      elsif var.name.include?("street") && var.name.include?("2")
        return "faker.Address.SecondaryAddress()"
      elsif var.name.include?("street")
        return "faker.Address.StreetAddress()"
      elsif var.name.include?("zip")
        return "faker.Address.ZipCode()"
      elsif var.name.include?("state")
        return "faker.Address.StateAbbr()"
      elsif var.name.include? "first name"
        return "faker.Name.FirstName()"
      elsif var.name.include? "last name"
        return "faker.Name.LastName()"
      elsif var.name.include? "phone"
        return "faker.Phone.PhoneNumber()"
      elsif var.name.include? "city"
        return "faker.Address.City()"
      elsif var.name.include? "country"
        return "faker.Address.Country()"
      elsif var.name.include? "county"
        return "faker.Address.County()"
      elsif var.name.include? "email"
        return "faker.Internet().Email(faker.Name.FirstName, faker.Name.LastName)"
      end

      return "faker.Lorem.Text();"
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::MethodFakerGet.new)
