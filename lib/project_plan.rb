
require 'singleton'

class ProjectPlan
    attr_accessor :classPlans, :models

    include Singleton

    def initialize
      @classPlans = Hash.new
      @models = Hash.new
    end

    def findClassPlan(unformattedName)
      for cp in @classPlans
        
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
      models = @models
      for model in @models[languageName]
        if model.name == modelName
          return model.findClassFunction(classPlugName, funPlugName)
        end
      end

      return nil
    end
end
