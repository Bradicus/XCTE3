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

require "code_elem_model.rb"
require "code_elem_project.rb"
require "x_c_t_e_plugin.rb"
require "user_settings.rb"
require "types.rb"

require "run_settings"
require "project_plans"
require "project_plan"
require "lang_profiles"
require "data_loader"
require "classes"

def isModelFile(filePath)
  return FileTest.file?(filePath) &&
           filePath.include?(".xml") &&
           !filePath.include?(".svn") &&
           (filePath.include?(".model.xml") || filePath.include?(".class.xml"))
end

def processProjectComponentGroup(project, pcGroup)
  currentDir = Dir.pwd

  # preload an extra set of data models, so they can be referenced if needed
  for pComponent in pcGroup.components
    #puts "Processing component: " + pComponent.tplPath
    projectPlan = ProjectPlan.new
    ProjectPlans.instance.plans[pComponent.language] = projectPlan
    Classes.reset()

    puts "Processing component path: " + pComponent.tplPath
    Find.find(currentDir + "/" + pComponent.tplPath) do |path|
      if isModelFile(path)
        puts "Processing model: " + path

        basepn = Pathname.new(currentDir + "/" + pComponent.tplPath)
        pn = Pathname.new(path)

        dataModel = CodeStructure::CodeElemModel.new
        DataLoader.loadXMLClassFile(dataModel, path, pComponent)

        language = XCTEPlugin::getLanguages()[pComponent.language]

        if (language == nil)
          puts "No language found for: " + pComponent.language
        end

        projectPlan.models << dataModel

        for cls in dataModel.classes
          cls.model = dataModel
          if (cls.language != nil)
            language = XCTEPlugin::getLanguages()[cls.language]
          else
            language = XCTEPlugin::getLanguages()[pComponent.language]
          end

          if language.has_key?(cls.ctype)
            if cls.path != nil
              newPath = pComponent.dest + "/" + cls.path
            else
              newPath = pComponent.dest + "/" + cls.namespace.get("/")
            end

            lClass = cls.clone()
            lClass.filePath = newPath
            lClass.name = language[lClass.ctype].getClassName(lClass)
            lClass.genCfg = pComponent

            if (lClass.language == nil)
              lClass.language = pComponent.language
            end

            if (cls.language == nil || cls.language == pComponent.language)
              if !File.directory?(newPath)
                FileUtils.mkdir_p(newPath)
                #   puts "Creating folder: " + newPath
              end

              projectPlan.classes << lClass
            end
          end
        end
      end
    end

    for plan in projectPlan.classes
      language = XCTEPlugin::getLanguages()[plan.language]

      puts "generating model " + plan.model.name + " class " + plan.ctype + " language: " + plan.language

      #project.singleFile = "map gen settings"

      if (project.singleFile == nil || project.singleFile == plan.model.name)
        srcFiles = language[plan.ctype].genSourceFiles(plan)

        for srcFile in srcFiles
          foundStart = false
          foundEnd = false
          overwriteFile = false
          fName = plan.filePath + "/" + srcFile.lfName + "." + srcFile.lfExtension

          if (File.file?(fName))
            plan.customCode = extractCustomCode(fName)

            if (plan.customCode != nil && plan.customCode.strip.length > 0)
              srcFile.lines = insertCustomCode(plan.customCode, srcFile)
            end
          end

          if (!File.file?(fName))
            overwriteFile = true
          else
            existingFile = File.new(File.join(plan.filePath, srcFile.lfName + "." + srcFile.lfExtension), mode: "r")
            fileData = existingFile.read
            genContents = srcFile.getContents

            if (fileData != genContents)
              overwriteFile = true
            end

            existingFile.close
          end
        end

        if (overwriteFile)
          puts "writing file: " + File.join(plan.filePath, srcFile.lfName + "." + srcFile.lfExtension)
          sFile = File.new(File.join(plan.filePath, srcFile.lfName + "." + srcFile.lfExtension), mode: "w")
          sFile << srcFile.getContents
          sFile.close
        end
      end
    end

    for pSubgroup in pcGroup.subGroups
      processProjectComponentGroup(project, pSubgroup)
    end
  end
end

def extractCustomCode(fName)
  customCode = nil
  foundStart = false
  foundEnd = false
  customCodeStart = "//+XCTE Custom Code Area"
  customCodeEnd = "//-XCTE Custom Code Area"

  File.open(fName).each_line do |line|
    if (!foundStart)
      if (line.include?(customCodeStart))
        foundStart = true
        customCode = ""
      end
    else
      if (!foundEnd)
        foundEnd = line.include?(customCodeEnd)
        if (line.include?(customCodeEnd))
          foundEnd = true
        else
          customCode += line
        end
      end
    end
  end

  return customCode
end

def insertCustomCode(customCode, srcRend)
  customCodeStart = "//+XCTE Custom Code Area"
  customCodeEnd = "//-XCTE Custom Code Area"

  finalLines = []
  started = false
  ended = false

  srcRend.lines.each_with_index { |line, index|
    if (!started && line.include?(customCodeStart))
      started = true
      finalLines << line
    elsif (started && !ended)
      if (line.include? customCodeEnd)
        ended = true
        finalLines << customCode + line
      end
    else
      finalLines << line
    end
  }

  return finalLines
end

# Main
options = ARGV
prj = CodeStructure::ElemProject.new

(0..options.length / 2 - 1).each do |i|
  if (options[i] == "-f")
    prj.singleFile = options[i + 1]
  end
end

codeRootDir = File.dirname(File.realpath(__FILE__))

UserSettings.instance.load(codeRootDir + "/../default_settings.xml")
#RunSettings.setUserSettings(cfg)

# Load variable types
Types.instance.load(codeRootDir + "/../types_basic.xml")

# Load language profiles
LangProfiles.instance.load(prj)

currentDir = Dir.pwd

if (!FileTest.file?(currentDir + "/xcte.project.xml"))
  puts "Unable to find project config file " + currentDir + "/xcte.project.xml"
  exit 0
end

prj.loadProject(currentDir + "/xcte.project.xml")

XCTEPlugin::loadPLugins

processProjectComponentGroup(prj, prj.componentGroup)

#XCTEPlugin::listPlugins
