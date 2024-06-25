class PluginManager
  @@plugins = Hash.new

  def self.plugins
    return @@plugins
  end

  # Attempts to find the desired class plugin for the desired language
  def self.find_method_plugin(lang, method)
    PluginManager.plugins[lang].each do |_plugKey, plug|
      return plug if plug.name == method && plug.category == "method"
    end

    nil
  end

  # Attempts to find the desired method plugin for the desired language
  def self.find_class_plugin(lang, pluginName, _ns = nil)
    PluginManager.plugins[lang].each do |_plugKey, plug|
      return plug if plug.name == pluginName
    end

    Log.warn("could not find plugin: " + pluginName.to_s)

    nil
  end

  # Attempts to find the desired method plugin for the desired language
  def self.find_class_plugin_by_type(lang, classType, _ns = nil)
    PluginManager.plugins[lang].each do |_plugKey, plug|
      return plug if plug.get_unformatted_class_name == classType
    end

    nil
  end

  # Attempts to find the desired project plugin for the desired language
  def self.find_project_plugin(lang, prjType)
    PluginManager.plugins[lang].each do |_plugKey, plug|
      return plug if plug.category == "project" && plug.name == prjType
    end

    nil
  end
end
