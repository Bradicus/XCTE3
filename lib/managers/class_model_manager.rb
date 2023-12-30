require 'managers/name_compare'

class ClassModelManager
  @@list = []

  def self.list
    return @@list
  end

  def self.reset
    @@list = []
  end

  def self.findClass(modelName, classPlugName)
    for c in @@list
      #  puts classPlugName + " " + c.plugName
      #  puts modelName + " " + c.model.name
      if c.plugName == classPlugName && NameCompare.matches(c.model.name, modelName)
        return c
      end
    end

    return nil
  end

  def self.findFeatureClasses(featureGroup)
    classes = []

    for c in @@list
      # puts c.plugName + " " + classPlugName
      # puts c.model.name + " " + className
      if c.model.featureGroup == featureGroup
        classes.push c
      end
    end

    return classes
  end

  def self.findVarClass(var, plugName = nil)
    dList = @@list
    for c in @@list
      # puts c.model.name + " " + var.getUType()
      # puts c.plugName + " " + plugName
      if !c.model.name.nil? && (NameCompare.matches(c.model.name, var.getUType) &&
                 (plugName.nil? || NameCompare.matches(c.plugName,
                                                       plugName))) && (c.namespace.same?(var.namespace) || !var.namespace.hasItems?)
        return c
      end
    end

    return nil
  end

  def self.findVarClassByName(model, var)
    dList = @@list
    for c in @@list
      if !c.model.name.nil?
        # puts c.model.name + " " + var.getUType()
        if !model.modelSet.nil?
          if NameCompare.matches(c.model.name, var.getUType + ' ' + model.modelSet) && c.namespace.same?(var.namespace)
            return c
          end
        elsif NameCompare.matches(c.model.name, var.getUType)
          if c.namespace.same?(var.namespace)
            return c
          end
        end
      end
    end

    return nil
  end

  def self.find_classes_with_data_model(cls)
    dm_classes = []

    for c in @@list
      # puts classPlugName + ' ' + c.plugName
      # puts modelName + ' ' + c.model.name

      # puts cls.model.name
      # puts cls.plugName
      if !c.dataClass.nil? && c.dataClass.matches(cls.model.name, cls.plugName)
        dm_classes.push c
      end
    end

    return dm_classes
  end

  def self.findClassFunction(classPlugName, funPlugName)
    cs = @@list # for debugging
    for c in @@list
      if c.plugName == classPlugName
        for fun in c.functions
          if fun.name == funPlugName
            return fun
          end
        end

        # if we found the class but not the function, we can return nil here
        return nil
      end
    end

    return nil
  end
end
