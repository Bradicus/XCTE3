class Classes
  @@list = Array.new

  def self.list
    return @@list
  end

  def self.reset
    @@list = Array.new
  end

  def self.findClass(classType, classPlugName)
    for c in @@list
      puts c.ctype + " " + c.model.name
      if (c.ctype == classType && nameMatches(c.model.name, classPlugName))
        return c
      end
    end

    return nil
  end

  def self.findVarClass(var, plugName = nil)
    dList = @@list
    for c in @@list
      if c.model.name != nil
        if (nameMatches(c.model.name, var.getUType()))
          # puts c.model.name + " " + var.getUType()
          # puts c.ctype + " " + plugName
          if (nameMatches(c.model.name, var.getUType()) &&
              (plugName == nil || nameMatches(c.ctype, plugName)))
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
    return n1.tr(" ", "").downcase == n2.tr(" ", "").downcase
  end

  def self.findClassFunction(classPlugName, funPlugName)
    cs = @@list # for debugging
    for c in @@list
      if (c.ctype == classPlugName)
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
