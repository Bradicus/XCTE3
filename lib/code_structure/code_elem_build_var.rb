##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

module CodeStructure
  class CodeElemBuildVar
    attr_accessor :name, :value
  
    def initialize(name, value)
      @name = name
      @value = value
    end
  end
end

