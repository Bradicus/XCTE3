##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemClassGroupRef < CodeElem
    attr_accessor :name, :variant, :feature_group

    def initialize(cls)
      super(nil, cls)

      @variant = nil
      @feature_group = nil
    end
  end
end

