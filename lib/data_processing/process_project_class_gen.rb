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

        if language.has_key?(cls.plug_name)
          if cls.path != nil
            newPath = pComponent.dest + "/" + cls.path
          else
            newPath = pComponent.dest + "/" + cls.namespace.get("/")
          end

          lClass = cls.clone()
          lClass.file_path = newPath.gsub(" ", "-")
          lClass.name = language[lClass.plug_name].get_class_name(lClass)
          lClass.gen_cfg = pComponent

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
