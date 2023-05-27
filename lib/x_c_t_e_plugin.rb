require "params/utils_each_var_params"
require "managers/class_plugin_manager"

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
  @@modelPlugins = Hash.new

  CAT_METHOD = "method"
  CAT_CLASS = "class"
  CAT_DERIVE = "derive"
  CAT_PROJECT = "project"

  def initialize
    # Need to be filled out by plugins
    @name
    @language
    @category
    @author
    @dependencies = Array.new
  end

  # Recursively load all plugins from the plugins folder
  def self.loadPLugins
    codeRootDir = File.dirname(File.realpath(__FILE__))
    workingDir = Dir.pwd

    # Find.find(codeRootDir + "/plugins_core/derive_models") do |path|
    #   if path.include?(".rb")
    #     require path
    #   end
    # end

    Dir.foreach(codeRootDir + "/plugins_core") do |langDir|
      next if !langDir.include?("lang_")
      ClassPluginManager.plugins[langDir[5..100]] = Hash.new()
    end

    ClassPluginManager.plugins.each do |langName, langMethods|
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
    ClassPluginManager.plugins[lang].each do |plugKey, plug|
      if plug.name == method && plug.category == "method"
        return plug
      end
    end

    return nil
  end

  # Attempts to find the desired method plugin for the desired language
  def self.findClassPlugin(lang, pluginName, ns = nil)
    ClassPluginManager.plugins[lang].each do |plugKey, plug|
      if plug.name == pluginName
        return plug
      end
    end

    return nil
  end

  # Attempts to find the desired method plugin for the desired language
  def self.findClassPluginByType(lang, classType, ns = nil)
    ClassPluginManager.plugins[lang].each do |plugKey, plug|
      if plug.getUnformattedClassName() == classType
        return plug
      end
    end

    return nil
  end

  # Attempts to find the desired project plugin for the desired language
  def self.findProjectPlugin(lang, prjType)
    ClassPluginManager.plugins[lang].each do |plugKey, plug|
      if plug.category == "project" && plug.name == prjType
        return plug
      end
    end

    return nil
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

  def self.getLanguages()
    return ClassPluginManager.plugins
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

  # Run a function on each variable in a class
  def eachVar(params)
    eachVarGrp(params.cls.model.varGroup, params.bld, params.separateGroups, params.varCb)
  end

  # Run a function on each variable in a variable group and subgroups
  def eachVarGrp(vGroup, bld, separateGroups, varFun)
    for var in vGroup.vars
      if var.elementId == CodeElem::ELEM_VARIABLE
        varFun.call(var)
      elsif bld != nil && var.elementId == CodeElem::ELEM_COMMENT
        bld.sameLine(getComment(var))
      elsif bld != nil && var.elementId == CodeElem::ELEM_FORMAT
        bld.add(var.formatText)
      end
    end

    for grp in vGroup.varGroups
      eachVarGrp(grp, bld, separateGroups, varFun)
      if (separateGroups && bld != nil)
        bld.separate
      end
    end
  end

  # Generate params object
  def uevParams()
    return UtilsEachVarParams.new()
  end
end
