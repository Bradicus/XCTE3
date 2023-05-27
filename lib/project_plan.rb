require "singleton"
require "managers/class_model_manager"

class ProjectPlan
  attr_reader :classes, :models

  def initialize
    @classes = Array.new
    @models = Array.new
  end

  def addClass(cls)
    if (cls == nil)
      Log.error("attempting to add null class to project plan")
    else
      @classes.push(cls)
    end
  end

  def addModel(mdl)
    if (mdl == nil)
      Log.error("attempting to add null model to project plan")
    else
      @models.push(mdl)
    end
  end

  def findClassPlan(unformattedName)
    for cp in @classes
    end
  end

  def findModel(unformattedName)
    for model in @models
      if model.name == unformattedName
        return model
      end
    end

    return nil
  end

  def findClassFunction(languageName, modelName, classPlugName, funPlugName)
    for model in @models
      if model.name == modelName
        return ClassModelManager.findClassFunction(classPlugName, funPlugName)
      end
    end

    return nil
  end
end
