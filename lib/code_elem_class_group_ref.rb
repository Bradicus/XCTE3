##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

#

module CodeStructure
  class CodeElemClassGroupRef < CodeElem
    attr_accessor :name, :variant, :featureGroup

    @name = nil
    @variant = nil
    @featureGroup = nil
  end
end
