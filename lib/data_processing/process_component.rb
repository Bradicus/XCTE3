require "data_processing/process_custom_code"
require "data_processing/process_project_class_gen"
require "data_loading/class_group_loader"
require "code_elem_classgroup"
require "class_groups"
require "debug"
require "env"

module DataProcessing
  class ProcessComponent
    # Loads a class from an xml node
    def self.process(project, pComponent, pcGroup)
      Log.info("Processing component with language: " + pComponent.language)
      currentDir = Dir.pwd
      projectPlan = ProjectPlan.new
      ProjectPlanManager.plans[pComponent.language] = projectPlan
      ClassModelManager.reset()
      ClassGroups.reset()

      Log.debug("Processing component path: " + pComponent.tplPath)

      # Load internal models
      Find.find(Env.getCodeRootDir() + "/../internal/clibs_templates") do |path|
        if isModelFile(path)
          Log.debug("Processing model: " + path)

          pn = Pathname.new(path)

          dataModel = CodeStructure::CodeElemModel.new
          DataLoading::ModelLoader.loadModelFile(dataModel, path, pComponent, InternalClassModelManager)
        end
      end

      # Load class groups
      Find.find(currentDir + "/" + pComponent.tplPath) do |path|
        if isClassgroupFile(path)
          Log.debug("Processing model: " + path)

          basepn = Pathname.new(currentDir + "/" + pComponent.tplPath)
          pn = Pathname.new(path)

          classGroup = CodeStructure::CodeElemClassgroup.new(nil)
          DataLoading::ClassGroupLoader.loadClassGroupFile(classGroup, path, pComponent)

          ClassGroups.add(classGroup)
        end
      end

      # Load models
      Find.find(currentDir + "/" + pComponent.tplPath) do |path|
        if isModelFile(path)
          Log.debug("Processing model: " + path)

          basepn = Pathname.new(currentDir + "/" + pComponent.tplPath)
          pn = Pathname.new(path)

          dataModel = CodeStructure::CodeElemModel.new
          DataLoading::ModelLoader.loadModelFile(dataModel, path, pComponent, ClassModelManager)

          language = XCTEPlugin::getLanguages()[pComponent.language]

          if (language == nil)
            Log.debug("No language found for: " + pComponent.language)
          end

          projectPlan.addModel(dataModel)
          ProcessProjectClassGen.process(dataModel, pComponent, projectPlan)
        end
      end

      # derviedModels = Array.new

      # # Load any derived classes defined in their own files
      # for model in projectPlan.models
      #   if (model.derivedFrom != nil)
      #     for dFromModel in projectPlan.models
      #       if model.derivedFrom.downcase == dFromModel.name.downcase
      #         #derviedModels.push(
      #         DerivedModelGenerator.getEditModelRepresentation(model, dFromModel, model.modelSet)
      #         #)
      #       end
      #     end
      #   end
      # end

      # Load any derived classes defined inside the file they are derived from
      # for model in projectPlan.models
      #   if (model.derivedModels.length > 0)
      #     for dFromModel in model.derivedModels
      #       projectPlan.addModel(dFromModel)
      #       ProcessProjectClassGen.process(dFromModel, pComponent, projectPlan)
      #     end
      #   end
      # end

      # Debug.logModels(projectPlan.models)

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
               (filePath.include?(".classgroup.xml"))
    end
  end
end
