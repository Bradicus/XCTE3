# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

class FunPluginParams
  attr_accessor :cls_spec, :cls_plugin, :bld, :fun_spec

  def initialize()
    @bld = nil
    @cls_spec = nil
    @cls_plug = nil
    @fun_spec = nil
  end

  def w_bld(bld)
    @bld = bld

    return self
  end

  def w_cls(cls_spec)
    @cls_spec = cls_spec

    return self
  end

  def w_cplug(cls_plug)
    @cls_plug = cls_plug

    return self
  end

  def w_fun(fun_spec)
    @fun_spec = fun_spec

    return self
  end
end
