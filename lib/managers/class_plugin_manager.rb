class ClassPluginManager
  @@plugins = Hash.new

  def self.plugins
    return @@plugins
  end
end
