# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

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
