##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemClassgroup < CodeStructure::CodeElem
    attr_accessor :feature_group, :cFor

    @feature_group = nil
    @cFor = nil

    def initialize(parentElem)
      super(nil, parentElem)
    end
  end
end
