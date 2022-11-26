##
#

class UtilsEachVarParams
  attr_accessor :cls, :bld, :separateGroups, :varCb

  @cls
  @bld
  @separateGroups
  @varCb

  def initialize(cls, bld, separateGroups, varCb)
    @cls = cls
    @bld = bld
    @separateGroups = separateGroups
    @varCb = varCb
  end
end
