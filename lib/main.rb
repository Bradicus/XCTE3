##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This file loads user settings generates code files off of template files in
# the templates folder and saves them in the generated folder

$:.unshift File.dirname(__FILE__)

require 'pathname'

require 'find.rb'
require 'fileutils.rb'
require 'code_elem_model.rb'
require 'code_elem_project.rb'
require 'x_c_t_e_plugin.rb'
require 'user_settings.rb'


def processProjectComponentGroup(project, pcGroup, cfg)
  currentDir = Dir.pwd
  for pComponent in pcGroup.components
    puts "Processing component: " + pComponent.path 
    if (pComponent.elementId == CodeElem::ELEM_TEMPLATE_DIRECTORY)
      puts "Processing component path: " + pComponent.path 
      Find.find(currentDir + "/" + pComponent.path) do |path|
        if FileTest.file?(path)
          if path.include?(".xml") && !path.include?(".svn")  # not perfect but good enough
            if (path.include?(".model.xml") || path.include?(".class.xml") )
              puts "Processing class: " + path
                    
              basepn = Pathname.new(currentDir + "/" + pComponent.path)
              pn = Pathname.new(path)

              dataModel = CodeStructure::CodeElemModel.new
              dataModel.loadXMLClassFile(path);
              
              #puts pComponent.languages.count()

              for langName in pComponent.languages
                language = XCTEPlugin::getLanguages()[langName]

                if (language == nil)
                  puts "No language found for: " + langName
                end
                              
                for genClass in dataModel.classes
                  if language.has_key?(genClass.ctype)

                    srcFiles = language[genClass.ctype].genSourceFiles(dataModel, genClass, cfg)
                    newPath = "./" + genClass.namespaceList.join("/")

                    if !File.directory?(newPath)
                      FileUtils.mkdir_p(newPath)
                  #   puts "Creating folder: " + newPath
                    end

                    puts "Current dir " + currentDir
                    puts "Abs root path " + basepn.to_path
                    puts "Rel Path " + newPath

                    for srcFile in srcFiles

                      puts srcFile.lfName
                      puts "Extension: " + srcFile.lfExtension.to_s

                      #puts OS.windows?
                      #if OS.windows?
                      #  sFile = File.new(newPath + "/" + srcFile.lfName + "." + srcFile.lfExtension, mode:"w", crlf_newline: true)
                      #else
                        sFile = File.new(newPath + "/" + srcFile.lfName + "." + srcFile.lfExtension, mode:"w")
                      #end
                      puts "writing file" + newPath + "/" + srcFile.lfName + "." + srcFile.lfExtension
                      sFile << srcFile.getContents
                      sFile.close                    
                    end
                  else
                    puts "Language " + langName + " has no class type defined: " + genClass.ctype
                  end        
                end
              end
            end   
          end                 
        end
      end
    end
  end
  
  for pSubgroup in pcGroup.subGroups
    processProjectComponentGroup(project, pSubgroup, cfg)
  end
end

XCTEPlugin::loadPLugins

codeRootDir = File.dirname(File.realpath(__FILE__))

cfg = UserSettings.new
cfg.load(codeRootDir + "/../default_settings.xml")

currentDir = Dir.pwd

if (!FileTest.file?(currentDir + "/xcte.project.xml"))
  puts "Unable to find project config file " + currentDir + "/xcte.project.xml"
  exit 0;
end

prj = CodeStructure::ElemProject.new
prj.loadProject(currentDir + "/xcte.project.xml")

processProjectComponentGroup(prj, prj.componentGroup, cfg)


#XCTEPlugin::listPlugins

