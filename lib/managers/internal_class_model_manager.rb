class InternalClassModelManager
  @@list = Array.new

  def self.list
    return @@list
  end

  def self.reset
    @@list = Array.new
  end

  def self.findClass(modelName, classplug_name)
    for c in @@list
      # puts classplug_name + " " + c.plug_name
      # puts modelName + " " + c.model.name
      if (c.plug_name == classplug_name && nameMatches(c.model.name, modelName))
        return c
      end
    end

    return nil
  end

  def self.findModel(modelName)
    for c in @@list
      # puts classplug_name + " " + c.plug_name
      # puts modelName + " " + c.model.name
      if (nameMatches(c.model.name, modelName))
        return c
      end
    end

    return nil
  end

  def self.findFeatureClasses(feature_group)
    classes = Array.new

    for c in @@list
      # puts c.plug_name + " " + classplug_name
      # puts c.model.name + " " + className
      if (c.model.feature_group == feature_group)
        classes.push c
      end
    end

    return classes
  end

  def self.findVarClass(var, plug_name = nil)
    dList = @@list
    for c in @@list
      if c.model.name != nil
        #puts c.model.name + " " + var.getUType()
        if (nameMatches(c.model.name, var.getUType()))
          # puts c.model.name + " " + var.getUType()
          # puts c.plug_name + " " + plug_name
          if (nameMatches(c.model.name, var.getUType()) &&
              (plug_name == nil || nameMatches(c.plug_name, plug_name)))
            if (c.namespace.same?(var.namespace))
              return c
            end
          end
        end
      end
    end

    return nil
  end

  def self.findVarClassByName(model, var)
    dList = @@list
    for c in @@list
      if c.model.name != nil
        #puts c.model.name + " " + var.getUType()
        if model.modelSet != nil
          if (nameMatches(c.model.name, var.getUType() + " " + model.modelSet))
            if (c.namespace.same?(var.namespace))
              return c
            end
          end
        else
          if (nameMatches(c.model.name, var.getUType()))
            if (c.namespace.same?(var.namespace))
              return c
            end
          end
        end
      end
    end

    return nil
  end

  def self.nameMatches(n1, n2)
    if (n1 != nil && n2 != nil)
      return n1.tr(" ", "").downcase == n2.tr(" ", "").downcase
    end

    return true
  end

  def self.findClassFunction(classplug_name, funplug_name)
    cs = @@list # for debugging
    for c in @@list
      if (c.plug_name == classplug_name)
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
