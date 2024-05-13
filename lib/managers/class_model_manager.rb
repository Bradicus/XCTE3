require "managers/name_compare"

class ClassModelManager
  @@list = []

  def self.list
    return @@list
  end

  def self.reset
    @@list = []
  end

  def self.findClass(modelName, classplug_name)
    for c in @@list
      #puts classplug_name + " " + c.plug_name
      #puts modelName + " " + c.model.name
      if c.plug_name == classplug_name && NameCompare.matches(c.model.name, modelName)
        return c
      end
    end

    Log.warn("could not find class with model: " + modelName.to_s + " plugin: " + classplug_name.to_s)

    return nil
  end

  def self.findFeatureClasses(feature_group)
    classes = []

    for c in @@list
      # puts c.plug_name + " " + classplug_name
      # puts c.model.name + " " + className
      if c.model.feature_group == feature_group
        classes.push c
      end
    end

    return classes
  end

  def self.findVarClass(var, plug_name = nil)
    dList = @@list
    for c in @@list
      # puts c.model.name + " " + var.getUType()
      # puts c.plug_name + " " + plug_name
      if !c.model.name.nil? && (NameCompare.matches(c.model.name, var.getUType) &&
                                (plug_name.nil? || NameCompare.matches(c.plug_name,
                                                                       plug_name))) && (c.namespace.same?(var.namespace) || !var.namespace.hasItems?)
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
          if NameCompare.matches(c.model.name, var.getUType + " " + model.modelSet) && c.namespace.same?(var.namespace)
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
      # puts classplug_name + ' ' + c.plug_name
      # puts modelName + ' ' + c.model.name

      # puts cls.model.name
      # puts cls.plug_name
      if !c.data_class.nil? && c.data_class.matches(cls.model.name, cls.plug_name)
        dm_classes.push c
      end
    end

    return dm_classes
  end

  def self.findClassFunction(classplug_name, funplug_name)
    cs = @@list # for debugging
    for c in @@list
      if c.plug_name == classplug_name
        for fun in c.functions
          if fun.name == funplug_name
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
