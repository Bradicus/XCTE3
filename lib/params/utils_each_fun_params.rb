##
#

class UtilsEachFunParams
  attr_accessor :cls, :bld, :funCb

  @cls
  @bld
  @funCb

  def initialize(cls, bld, funCb)
    @cls = cls
    @bld = bld
    @funCb = funCb
  end
end
