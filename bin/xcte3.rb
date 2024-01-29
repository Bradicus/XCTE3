#!/usr/bin/env ruby

##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This file loads user settings generates code files off of template files in
# the templates folder and saves them in the generated folder

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "pathname"
require "find"
require "fileutils"
require "log"

require "env"

require "data_loading/project_loader"
require "data_loading/model_loader"
require "data_processing/process_component"

require "code_elem_model.rb"
require "code_elem_project.rb"
require "x_c_t_e_plugin.rb"
require "user_settings.rb"
require "types.rb"

require "run_settings"
require "project_plan"
require "active_component"
require "active_project"
require "lang_profiles"
require "managers/class_model_manager"
require "managers/internal_class_model_manager"
require "managers/project_plan_manager"

def processProjectComponentGroup(project, pcGroup)
  currentDir = Dir.pwd

  # preload an extra set of data models, so they can be referenced if needed
  for pComponent in pcGroup.components
    ActiveComponent.set(pComponent)
    DataProcessing::ProcessComponent.process(project, pComponent, pcGroup)
  end
end

# Main
options = ARGV
prj = CodeStructure::ElemProject.new
ActiveProject.set(prj)

(0..options.length / 2 - 1).each do |i|
  if (options[i] == "-f")
    prj.singleFile = options[i + 1]
  end
end

Env.setCodeRootDir(File.dirname(File.realpath(__FILE__)))

UserSettings.instance.load(Env.getCodeRootDir() + "/../default_settings.xml")
#RunSettings.setUserSettings(cfg)

# Load variable types
Types.instance.load(Env.getCodeRootDir() + "/../types_basic.xml")

# Load language profiles
LangProfiles.instance.load(prj)

currentDir = Dir.pwd

if (!FileTest.file?(currentDir + "/xcte.project.xml"))
  Log.debug("Unable to find project config file " + currentDir + "/xcte.project.xml")
  exit 0
end

DataLoading::ProjectLoader.loadProject(prj, currentDir + "/xcte.project.xml")

XCTEPlugin::loadPLugins

processProjectComponentGroup(prj, prj.componentGroup)

#XCTEPlugin::listPlugins
