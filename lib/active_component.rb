# Stores the component currently being processed
class ActiveComponent
  @comp

  def self.get()
    return @comp
  end

  def self.set(aComp)
    @comp = aComp
  end
end
