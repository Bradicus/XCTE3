require "singleton"
require "classes"

class ProjectPlans
  attr_accessor :plans

  include Singleton

  def initialize
    @plans = Hash.new
  end
end
