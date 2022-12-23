##
# Class:: Accessor
#

class Accessor
  attr_accessor :hasGet, :hasSet, :var

  @var
  @hasGet
  @hasSet

  def initialize(var, hasGet, hasSet)
    @var = var
    @hasGet = hasGet
    @hasSet = hasSet
  end
end
