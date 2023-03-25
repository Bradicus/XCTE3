class IncludeUtil
  attr_accessor :pName

  @pName = nil
  @mdl = nil
  @var = nil

  def self.init(pName)
    newInc = IncludeUtil.new
    newInc.pName = pName
    return newInc
  end

  def wModel(mdl)
    @mdl = mdl
    return self
  end

  def plugName(pName)
    @pName = pName
    return self
  end

  def forVar(var)
    @var = var
    return self
  end

  def addTo(tgtClass)
    clsPlug = XCTEPlugin::findClassPlugin(tgtClass.genCfg.language, @pName)
    clsGen = @mdl.findClassModel(@pName)

    if clsPlug != nil && clsGen != nil
      tgtClass.addInclude(clsPlug.getDependencyPath(clsGen), clsPlug.getClassName(clsGen))
    end
  end
end
