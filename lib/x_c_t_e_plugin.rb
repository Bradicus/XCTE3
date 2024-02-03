require 'params/utils_each_var_params'
require 'managers/class_plugin_manager'

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class is the base class for all plugins.  It hold the static list of
# registered plugins

class XCTEPlugin
  attr_accessor :pluginRegistry, :languagePlugins, :name, :language, :category, :author

  # @@pluginRegistry = Hash.new
  @@modelPlugins = {}

  CAT_METHOD = 'method'
  CAT_CLASS = 'class'
  CAT_DERIVE = 'derive'
  CAT_PROJECT = 'project'

  def initialize
    # Need to be filled out by plugins
    @dependencies = []
  end

  # Recursively load all plugins from the plugins folder
  def self.loadPLugins
    codeRootDir = __dir__
    workingDir = Dir.pwd

    # Find.find(codeRootDir + "/plugins_core/derive_models") do |path|
    #   if path.include?(".rb")
    #     require path
    #   end
    # end

    Dir.foreach(codeRootDir + '/plugins_core') do |langDir|
      next if !langDir.include?('lang_')

      ClassPluginManager.plugins[langDir[5..100]] = {}
    end

    ClassPluginManager.plugins.each do |langName, _langMethods|
      langDir = codeRootDir + '/plugins_core/lang_' + langName
      if Dir.exist?(langDir)
        Find.find(langDir) do |path|
          if FileTest.file?(path) && (path.include?('.rb') && !path.include?('.svn')) # not perfect but good enough
            # puts "Loading plugin: " + path + " for language: " + langName
            require path
          end
        end
      end
      langDir = 'xcte/plugins_custom/lang_' + langName
      if Dir.exist?(langDir)
        Find.find(langDir) do |path|
          if FileTest.file?(path) && (path.include?('.rb') && !path.include?('.svn')) # not perfect but good enough
            # puts "Loading plugin: " + path
            require workingDir + '/' + path
          end
        end
      end
    end

    #    ClassPluginManager.plugins.each do |langName, langMethods|
    #      langMethods = findLangPlugins(langName)
    #    end
  end

  # Register a plugin in the plugin repository
  def self.registerPlugin(plug)
    ClassPluginManager.plugins[plug.language][plug.name] = plug
  end

  # Register a plugin in the plugin repository
  def self.registerModelPlugin(plug)
    @@modelPlugins[plug.name] = plug
  end

  #  # Attempts to find the desired class plugin for the desired language
  #  def self.findLangPlugins(langName)
  #    pluginSet = Hash.new()
  #
  #    @@pluginRegistry.each do |plugKey, plug|
  #
  ##      puts "comparing plug lang " + plug.language + "   to lang" + langName
  #      if ("lang_" + plug.language) == langName
  #        pluginSet[plugKey] = plug
  #
  #        puts "adding plugin " + plugKey
  #      end
  #    end
  #
  #    puts "plugin count for " + langName +  ": " + pluginSet.count().to_s
  #
  #    return pluginSet
  #  end

  # Attempts to find the desired class plugin for the desired language
  def self.findMethodPlugin(lang, method)
    ClassPluginManager.plugins[lang].each do |_plugKey, plug|
      return plug if plug.name == method && plug.category == 'method'
    end

    nil
  end

  # Attempts to find the desired method plugin for the desired language
  def self.findClassPlugin(lang, pluginName, _ns = nil)
    ClassPluginManager.plugins[lang].each do |_plugKey, plug|
      return plug if plug.name == pluginName
    end

    Log.warn("could not find plugin: " + pluginName.to_s)

    nil
  end

  # Attempts to find the desired method plugin for the desired language
  def self.findClassPluginByType(lang, classType, _ns = nil)
    ClassPluginManager.plugins[lang].each do |_plugKey, plug|
      return plug if plug.get_unformatted_class_name == classType
    end

    nil
  end

  # Attempts to find the desired project plugin for the desired language
  def self.findProjectPlugin(lang, prjType)
    ClassPluginManager.plugins[lang].each do |_plugKey, plug|
      return plug if plug.category == 'project' && plug.name == prjType
    end

    nil
  end

  # Attempts to find the desired derived model plugin for the desired language
  # def self.findDerivePlugin(prjType)
  #   @@modelPlugins.each do |plugKey, plug|
  #     if plug.category == "derive" && plug.name == prjType
  #       return plug
  #     end
  #   end

  #   return nil
  # end

  def self.getLanguages
    ClassPluginManager.plugins
  end

  def self.getPlugins
    @@pluginRegistry
  end

  # Prints out a list of all the registered plugins and their information
  def self.listPlugins
    for plug in @@pluginRegistry
      puts 'Name:     ' + plug.name
      puts 'Language: ' + plug.language
      puts 'Category: ' + plug.category
      puts 'Author:   ' + plug.author
    end
  end

  # Run a function on each variable in a class
  def each_var(params)
    each_var_grp(params.cls.model.varGroup, params.bld, params.separateGroups, params.varCb)
  end

  # Run a function on each variable in a variable group and subgroups
  def each_var_grp(vGroup, bld, separateGroups, varFun)
    for var in vGroup.vars
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        varFun.call(var)
      elsif !bld.nil? && var.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        bld.same_line(getComment(var))
      elsif !bld.nil? && var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        bld.add(var.formatText)
      end
    end

    for grp in vGroup.varGroups
      each_var_grp(grp, bld, separateGroups, varFun)
      bld.separate if separateGroups && !bld.nil?
    end
  end

  # Generate params object
  def uevParams
    UtilsEachVarParams.new
  end
end
