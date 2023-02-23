require "data_processing/process_custom_code"

module DataProcessing
  class ProcessComponent
    # Loads a class from an xml node
    def self.process(project, pComponent, pcGroup)
      Log.info("Processing component with language: " + pComponent.language)
      currentDir = Dir.pwd
      projectPlan = ProjectPlan.new
      ProjectPlans.instance.plans[pComponent.language] = projectPlan
      Classes.reset()

      Log.debug("Processing component path: " + pComponent.tplPath)

      Find.find(currentDir + "/" + pComponent.tplPath) do |path|
        if isModelFile(path)
          Log.debug("Processing model: " + path)

          basepn = Pathname.new(currentDir + "/" + pComponent.tplPath)
          pn = Pathname.new(path)

          dataModel = CodeStructure::CodeElemModel.new
          DataLoading::ModelLoader.loadModelFile(dataModel, path, pComponent)

          language = XCTEPlugin::getLanguages()[pComponent.language]

          if (language == nil)
            Log.debug("No language found for: " + pComponent.language)
          end

          projectPlan.models << dataModel

          for cls in dataModel.classes
            cls.model = dataModel
            if (cls.language != nil)
              language = XCTEPlugin::getLanguages()[cls.language]
            else
              language = XCTEPlugin::getLanguages()[pComponent.language]
            end

            if language.has_key?(cls.plugName)
              if cls.path != nil
                newPath = pComponent.dest + "/" + cls.path
              else
                newPath = pComponent.dest + "/" + cls.namespace.get("/")
              end

              lClass = cls.clone()
              lClass.filePath = newPath
              lClass.name = language[lClass.plugName].getClassName(lClass)
              lClass.genCfg = pComponent

              if (lClass.language == nil)
                lClass.language = pComponent.language
              end

              if (cls.language == nil || cls.language == pComponent.language)
                projectPlan.classes << lClass
              end
            end
          end
        end
      end

      derviedModels = Array.new

      # Load any derived classes
      for model in projectPlan.models
        if (model.derivedFrom != nil)
          for dFromModel in projectPlan.models
            if model.derivedFrom.downcase == dFromModel.name.downcase
              #derviedModels.push(
              DerivedModelGenerator.getEditModelRepresentation(model, dFromModel, model.derivedFor)
              #)
            end
          end
        end
      end

      #    projectPlan.models += derviedModels

      for plan in projectPlan.classes
        language = XCTEPlugin::getLanguages()[plan.language]

        Log.debug("generating model " + plan.model.name + " class " + plan.plugName + " language: " + plan.language +
                  "  namespace: " + plan.namespace.get("."))

        #project.singleFile = "map gen settings"

        if (project.singleFile == nil || project.singleFile == plan.model.name)
          srcFiles = language[plan.plugName].genSourceFiles(plan)

          for srcFile in srcFiles
            foundStart = false
            foundEnd = false
            overwriteFile = false
            fName = plan.filePath + "/" + srcFile.lfName + "." + srcFile.lfExtension

            if (File.file?(fName))
              plan.customCode = ProcessCustomCode.extractCustomCode(fName)

              if (plan.customCode != nil && plan.customCode.strip.length > 0)
                srcFile.lines = ProcessCustomCode.insertCustomCode(plan.customCode, srcFile)
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
            Log.debug("writing file: " + File.join(plan.filePath, srcFile.lfName + "." + srcFile.lfExtension))
            if !File.directory?(plan.filePath)
              FileUtils.mkdir_p(plan.filePath)
              #   Log.debug("Creating folder: " + newPath
            end
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

    def self.isModelFile(filePath)
      return FileTest.file?(filePath) &&
               filePath.include?(".xml") &&
               !filePath.include?(".svn") &&
               (filePath.include?(".model.xml") || filePath.include?(".class.xml"))
    end

    def self.isClassgroupFile(filePath)
      return FileTest.file?(filePath) &&
               filePath.include?(".xml") &&
               !filePath.include?(".svn") &&
               (filePath.include?(".model.xml") || filePath.include?(".class.xml"))
    end
  end
end
