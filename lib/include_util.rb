require "managers/plugin_manager.rb"

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

  def plug_name(pName)
    @pName = pName
    return self
  end

  def forVar(var)
    @var = var
    return self
  end

  def addTo(tgtClass)
    clsPlug = PluginManager.find_class_plugin(tgtClass.gen_cfg.language, @pName)
    clsGen = @mdl.findClassModel(@pName)

    if clsPlug != nil && clsGen != nil
      tgtClass.addInclude(clsPlug.get_dependency_path_w_file(clsGen), clsPlug.get_class_name(clsGen))
    end
  end
end
