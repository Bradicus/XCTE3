##

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
  @@languagePlugins = Hash.new

  CAT_METHOD = "method" # Right now there is only one plugin category, methods
  CAT_CLASS = "class"
  CAT_PROJECT = "project"

  def initialize
    # Need to be filled out by plugins
    @name
    @language
    @category
    @author
  end

  # Recursively load all plugins from the plugins folder
  def self.loadPLugins
    codeRootDir = File.dirname(File.realpath(__FILE__))
    workingDir = Dir.pwd

    Dir.foreach(codeRootDir + "/plugins_core") do |langDir|
      next if !langDir.include?("lang_")
      @@languagePlugins[langDir[5..100]] = Hash.new()
    end

    @@languagePlugins.each do |langName, langMethods|
      langDir = codeRootDir + "/plugins_core/lang_" + langName
      if Dir.exist?(langDir)
        Find.find(langDir) do |path|
          if FileTest.file?(path)
            if path.include?(".rb") && !path.include?(".svn") # not perfect but good enough
              #puts "Loading plugin: " + path + " for language: " + langName
              require path
            end
          end
        end
      end
      langDir = "xcte/plugins_custom/lang_" + langName
      if Dir.exist?(langDir)
        Find.find(langDir) do |path|
          if FileTest.file?(path)
            if path.include?(".rb") && !path.include?(".svn") # not perfect but good enough
              #puts "Loading plugin: " + path
              require workingDir + "/" + path
            end
          end
        end
      end
    end

    #    @@languagePlugins.each do |langName, langMethods|
    #      langMethods = findLangPlugins(langName)
    #    end
  end

  # Register a plugin in the plugin repository
  def self.registerPlugin(plug)
    @@languagePlugins[plug.language][plug.name] = plug
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
    @@languagePlugins[lang].each do |plugKey, plug|
      if plug.name == method && plug.category == "method"
        return plug
      end
    end

    return nil
  end

  # Attempts to find the desired class plugin for the desired language
  #  def self.findClassPlugin(lang, classType)
  #    for plug in @@languagePlugins
  #      if plug.language == lang && plug.name == classType && plug.category == "class"
  #        return plug
  #      end
  #    end
  #
  #    return nil
  #  end

  # Attempts to find the desired project plugin for the desired language
  def self.findProjectPlugin(lang, prjType)
    @@languagePlugins[lang].each do |plugKey, plug|
      if plug.category == "project" && plug.name == prjType
        return plug
      end
    end

    return nil
  end

  def self.getLanguages()
    return @@languagePlugins
  end

  def self.getPlugins()
    return @@pluginRegistry
  end

  # Prints out a list of all the registered plugins and their information
  def self.listPlugins
    for plug in @@pluginRegistry
      puts "Name:     " + plug.name
      puts "Language: " + plug.language
      puts "Category: " + plug.category
      puts "Author:   " + plug.author
    end
  end
end
