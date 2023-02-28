# Keeps a list of classgroups available

class ClassGroups
  @@list = Array.new

  def self.add(grp)
    Log.info("adding classgroup: " + grp.name)
    @@list.push(grp)
  end

  def self.get(grpName)
    for clsGen in @@list
      if clsGen.name == grpName
        return clsGen
      end
    end

    return nil
  end

  def self.reset()
    @@list = Array.new
  end
end
