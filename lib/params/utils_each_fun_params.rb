# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

class UtilsEachFunParams
  attr_accessor :cls, :bld, :funCb

  @cls
  @bld
  @funCb
  @separateGroups = false

  def w_cls(cls)
    @cls = cls

    return self
  end

  def w_bld(bld)
    @bld = bld
    return self
  end

  def w_fun_cb(cb)
    @funCb = cb
    return self
  end

  def w_separate(separateGroups)
    @separateGroups = separateGroups
    return self
  end
end
