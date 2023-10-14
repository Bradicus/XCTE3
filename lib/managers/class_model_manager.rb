class ClassModelManager
  @@list = Array.new

  def self.list
    return @@list
  end

  def self.reset
    @@list = Array.new
  end

  def self.findClass(modelName, classPlugName)
    for c in @@list
    #  puts classPlugName + " " + c.plugName
    #  puts modelName + " " + c.model.name
      if (c.plugName == classPlugName && nameMatches(c.model.name, modelName))
        return c
      end
    end

    return nil
  end

  def self.findFeatureClasses(featureGroup)
    classes = Array.new

    for c in @@list
      # puts c.plugName + " " + classPlugName
      # puts c.model.name + " " + className
      if (c.model.featureGroup == featureGroup)
        classes.push c
      end
    end

    return classes
  end

  def self.findVarClass(var, plugName = nil)
    dList = @@list
    for c in @@list
      if c.model.name != nil
        #puts c.model.name + " " + var.getUType()
        if (nameMatches(c.model.name, var.getUType()))
          #uts c.model.name + " " + var.getUType()
          #puts c.plugName + " " + plugName
          if (nameMatches(c.model.name, var.getUType()) &&
              (plugName == nil || nameMatches(c.plugName, plugName)))
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

  def self.findClassFunction(classPlugName, funPlugName)
    cs = @@list # for debugging
    for c in @@list
      if (c.plugName == classPlugName)
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
