##
#

class UtilsEachVarParams
  attr_accessor :cls, :bld, :separateGroups, :varCb, :bgCb, :agCb

  @cls = nil
  @bld = nil
  @separateGroups
  @varCb
  @bgCb = nil
  @agCb = nil

  def wCls(cls)
    @cls = cls

    return self
  end

  def wBld(bld)
    @bld = bld
    return self
  end

  def wSeparate(separateGroups)
    @separateGroups = separateGroups
    return self
  end

  def wVarCb(varCb)
    @varCb = varCb
    return self
  end

  def wBeforeGroupCb(bgCb)
    @bgCb = bgCb
    return self
  end

  def wAfterGroupCb(agCb)
    @agCb = agCb
    return self
  end

  # def initialize(cls, bld, separateGroups, varCb)
  #   @cls = cls
  #   @bld = bld
  #   @separateGroups = separateGroups
  #   @varCb = varCb
  # end
end
