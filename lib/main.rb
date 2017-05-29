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

require 'find.rb'
require 'fileutils.rb'
require 'code_elem_class.rb'
require 'code_elem_project.rb'
require 'x_c_t_e_plugin.rb'
require 'user_settings.rb'

XCTEPlugin::loadPLugins

cfg = UserSettings.new
cfg.load("../default_settings.xml")

if (ARGV.length != 3)
  puts "missing parameters"
  exit 0;
end

templatePath = ARGV[0]
generatePath = ARGV[1]
languageName = ARGV[2]

puts "checking path " + templatePath
  
Find.find(templatePath) do |path|
  if FileTest.file?(path)
    if path.include?(".xml") && ! path.include?(".svn")  # not perfect but good enough

      if (path.include?(".project.xml"))
        puts "Processing project: " + path
        prj = CodeStructure::ElemProject.new
        prj.loadProject(path)
        makePlugin = XCTEPlugin.findProjectPlugin("cpp", "makefile");
        makeFiles = makePlugin.genSourceFiles(prj, cfg)

        cMakePlugin = XCTEPlugin.findProjectPlugin("cpp", "cmake");
        cMakeFiles = cMakePlugin.genSourceFiles(prj, cfg)

        cppNewPath = generatePath

        if !File.directory?(cppNewPath)
          FileUtils.mkdir_p(cppNewPath)
        end

        ## Write all cpp make files
        for mkFile in makeFiles
          mFile = File.new(cppNewPath + "/" + mkFile.lfName + "." + prj.name, "w")
          mFile << mkFile.getContents
          mFile.close
        end

        ## Write all cpp cmake files
        for mkFile in cMakeFiles
          mFile = File.new(cppNewPath + "/CMakeLists.txt", "w")
          mFile << mkFile.getContents
          mFile.close
        end

      end

      if (path.include?(".model.xml"))
        puts "Processing class: " + path
		
        fileGenPath = File.dirname(path[templatePath.length..-1])		

        codeClass = CodeStructure::CodeElemClass.new
        codeClass.loadXMLClassFile(path);
        
        puts XCTEPlugin::getLanguages().count()
		
        language = XCTEPlugin::getLanguages()[languageName]
        if (language == nil)
          puts "No language found for: " + languageName
        end
      
        classTypes = codeClass.classType.split(' ')
        
        for classType in classTypes
          if language.has_key?(classType)
            
            srcFiles = language[classType].genSourceFiles(codeClass, cfg)
            newPath = generatePath + fileGenPath

            if !File.directory?(newPath)
              FileUtils.mkdir_p(newPath)
           #   puts "Creating folder: " + newPath
            end

            for srcFile in srcFiles
              puts OS.windows?
              if OS.windows?
                sFile = File.new(newPath + "/" + srcFile.lfName + "." + srcFile.lfExtension, mode:"w", crlf_newline: true)
              else
                sFile = File.new(newPath + "/" + srcFile.lfName + "." + srcFile.lfExtension, mode:"w")
              end
			        puts "writing file" << newPath + "/" + srcFile.lfName + "." + srcFile.lfExtension
              sFile << srcFile.getContents
              sFile.close
            end
          end        
        end
      end
    end
  end
end 

#XCTEPlugin::listPlugins

