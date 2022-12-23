##
# Class:: Accessor
#

class Accessors
  attr_accessor :readers, :writers, :both

  def initialize
    @readers = Array.new
    @writers = Array.new
    @both = Array.new
  end

  def add(accessor)
    if (accessor.hasGet && accessor.hasSet)
      @both.push(accessor)
    elsif accessor.hasGet
      @readers.push(accessor)
    elsif accessor.hasSet
      @writers.push(accessor)
    end
  end
end
