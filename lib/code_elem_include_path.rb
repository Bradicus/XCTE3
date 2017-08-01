# Contains the list of includes for a class generator

class CodeElemIncludePath
  attr_accessor :path, :includes

  def initialize()
    @path = Array.new
    @includes = Array.new
  end

end