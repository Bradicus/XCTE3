class PluginManager
  @@plugins = Hash.new

  def self.plugins
    return @@plugins
  end
end
