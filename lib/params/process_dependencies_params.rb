##
#

class ProcessDependenciesParams
  attr_accessor :cls, :bld, :funCb

  @cls
  @bld
  @fun

  def initialize(cls, bld, fun)
    @cls = cls
    @bld = bld
    @fun = fun
  end
end
