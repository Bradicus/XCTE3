##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

#

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemClassGroupRef < CodeStructure::CodeElem
    attr_accessor :name, :variant, :feature_group

    @name = nil
    @variant = nil
    @feature_group = nil
  end
end
