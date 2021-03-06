class Classes
  @@list = Array.new

  def self.list
    return @@list
  end

  def self.findClass(classPlugName)
    for c in @@list
      if (c.ctype == classPlugName)
        return c
      end
    end

    return nil
  end

  def self.findVarClass(var)
    for c in @@list
      if (c.model.name != nil && var.vtype != nil && (c.model.name.tr(" ", "").downcase == var.vtype.tr(" ", "").downcase))
        return c
      end
    end

    return nil
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
