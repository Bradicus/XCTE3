module XCTEJava
  class MethodFakerGet < XCTEPlugin
    def initialize
      super

      @name = 'method_service_datagen_faker_get'
      @language = 'java'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns the code for the content for this function
    def render_function(cls, bld, _fun)
      # process class variables

      className = Utils.instance.get_styled_class_name(cls.model.name)
      bld.start_function('void populateRandom(Faker faker, ' + className + ' item)')

      genPopulate(cls, bld, 'item.')

      bld.endFunction
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse('com.github.javafaker.Faker')

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wVarCb(lambda { |var|
        if var.getUType().downcase == 'datetime'
          cls.addUse('java.util.concurrent.TimeUnit')
        end
      }))
    end

    # process variable group
    def genPopulate(cls, bld, name = '')
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        varName = Utils.instance.get_styled_variable_name(var)

        if Utils.instance.is_primitive(var)
          if var.name == 'id'
          elsif !var.isList
            bld.add(name + varName + ' = ' + getFakerAssignment(var) + ';')
          else
            bld.add(name + varName + '.push(' + getFakerAssignment(var) + ');')
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
        return '1'
      elsif Utils.instance.is_numeric?(var)
        return 'faker.random.numeric(8)'
      elsif varType.start_with?('datetime')
        return 'LocalDateTime.ofInstant(faker.date().past(100, TimeUnit.DAYS).toInstant(), null)'
      elsif varType.start_with?('boolean')
        return 'faker.bool().bool()'
      elsif var.name.include?('street') && var.name.include?('2')
        return 'faker.address().secondaryAddress()'
      elsif var.name.include?('street')
        return 'faker.address().streetAddress()'
      elsif var.name.include?('zip')
        return 'faker.address().zipCode()'
      elsif var.name.include?('state')
        return 'faker.address().stateAbbr()'
      elsif var.name.include? 'first name'
        return 'faker.name().firstName()'
      elsif var.name.include? 'last name'
        return 'faker.name().lastName()'
      elsif var.name.include? 'city'
        return 'faker.address().city()'
      elsif var.name.include? 'country'
        return 'faker.address().country()'
      elsif var.name.include? 'county'
        return 'faker.address().county()'
      elsif var.name.include? 'email'
        return 'faker.name().firstName() + "." + faker.name().lastName() + "@example.com"'
      end

      return 'faker.letterify("????????");'
    end
  end
end

XCTEPlugin.registerPlugin(XCTEJava::MethodFakerGet.new)
