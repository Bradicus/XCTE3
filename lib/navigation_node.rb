class NavigationNode
  attr_accessor :name, :link, :children

  @name = nil
  @link = nil
  @children = Array.new

  def initialize(name, link)
    @name = name
    @link = link
    @children = Array.new
  end
end
