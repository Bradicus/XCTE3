module DataProcessing
  class ProcessProjectClassGen
    def self.process(dataModel, pComponent, projectPlan)
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
            projectPlan.addClass(lClass)
          end
        end
      end
    end
  end
end
