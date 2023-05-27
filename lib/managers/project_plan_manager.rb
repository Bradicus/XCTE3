require "active_component"

class ProjectPlanManager
  attr_accessor :plans

  @@plans = Hash.new

  def self.plans()
    return @@plans
  end

  def self.current()
    aComp = ActiveComponent.get().language
    plan = @@plans
    return @@plans[aComp]
  end
end
