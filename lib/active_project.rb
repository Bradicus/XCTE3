# Stores the component currently being processed
class ActiveProject
  @comp

  def self.get()
    return @comp
  end

  def self.set(aComp)
    @comp = aComp
  end
end
