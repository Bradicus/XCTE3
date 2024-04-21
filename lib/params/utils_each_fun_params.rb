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

  def initialize(cls, bld, funCb)
    @cls = cls
    @bld = bld
    @funCb = funCb
  end
end
