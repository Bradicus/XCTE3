require "singleton"
require "managers/class_plugin_manager"

class ProjectPlans
  attr_accessor :plans

  include Singleton

  def initialize
    @plans = Hash.new
  end
end
