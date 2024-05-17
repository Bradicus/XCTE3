require "data_processing/process_custom_code"
require "data_processing/process_project_class_gen"
require "data_loading/class_group_loader"
require "code_structure/code_elem_classgroup"
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
      ClassModelManager.reset
      ClassGroups.reset

      Log.debug("Processing component path: " + pComponent.tplPath)

      # Load internal models
      Find.find(Env.getCodeRootDir + "/../internal/clibs_templates") do |path|
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

          language = XCTEPlugin.getLanguages[pComponent.language]

          Log.debug("No language found for: " + pComponent.language) if language.nil?

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

      for cls_spec in projectPlan.classes
        language = XCTEPlugin.getLanguages[cls_spec.language]
        plugin = language[cls_spec.plug_name]

        Log.debug("generating model " + cls_spec.model.name + " class " + cls_spec.plug_name + " language: " + cls_spec.language +
                  "  namespace: " + cls_spec.namespace.get("."))

        # project.singleFile = "map gen settings"

        if project.singleFile.nil? || project.singleFile == cls_spec.model.name
          srcFiles = language[cls_spec.plug_name].gen_source_files(cls_spec)

          for srcFile in srcFiles
            foundStart = false
            foundEnd = false
            overwriteFile = false

            file_path = File.join(pComponent.dest, plugin.get_file_path(cls_spec))
            fName = File.join(file_path, srcFile.lfName + "." + srcFile.lfExtension)

            if File.file?(fName)
              cls_spec.custom_code = ProcessCustomCode.extractCustomCode(fName)

              if !cls_spec.custom_code.nil? && cls_spec.custom_code.strip.length > 0
                srcFile.lines = ProcessCustomCode.insertCustomCode(cls_spec.custom_code, srcFile)
                for line in srcFile.lines
                  line.strip! if line.strip.empty?
                end
              end
            end

            if !File.file?(fName)
              overwriteFile = true
            else
              existingFile = File.new(fName, mode: "r")
              fileData = existingFile.read
              genContents = srcFile.getContents

              overwriteFile = true if fileData != genContents

              existingFile.close
            end

            if overwriteFile
              Log.debug("writing file: " + fName)
              if !File.directory?(file_path)
                FileUtils.mkdir_p(file_path)
                #   Log.debug("Creating folder: " + newPath
              end
              sFile = File.new(fName, mode: "w")
              sFile << srcFile.getContents
              sFile.close
            end
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
             filePath.include?(".classgroup.xml")
    end
  end
end
