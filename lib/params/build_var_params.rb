# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

class BuildVarParams
  attr_accessor :value, :pComp, :model, :clsGen

  @value = nil
  @pComp = nil
  @model = nil
  @clsGen = nil
  @xml = nil

  def wXml(xml)
    @xml = xml

    return self
  end

  def wCls(cls)
    @clsGen = cls

    return self
  end

  def wComp(pComp)
    @pComp = pComp
    return self
  end

  def wModel(model)
    @model = model
    return self
  end

  def wValue(value)
    @value = value
    return self
  end
end
