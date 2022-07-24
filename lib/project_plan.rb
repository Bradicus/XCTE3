require "singleton"
require "classes"

class ProjectPlan
  attr_accessor :classes, :models

  def initialize
    @classes = Array.new
    @models = Array.new
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
        return Classes.findClassFunction(classPlugName, funPlugName)
      end
    end

    return nil
  end
end
