class Debug
  def self.logModels(models)
    for model in models
      Log.info("Model: " + model.name)
      for cls in model.classes
        Log.info("    class plugin: " + cls.plug_name)
      end
      #Log.info("Derived classes: " + model.derivedModels.length.to_s())
    end
  end
end
