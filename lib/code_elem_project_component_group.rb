##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores data for the project components

require "code_elem.rb"

module CodeStructure
  class CodeElemProjectComponentGroup < CodeElem
    attr_accessor :name, :components, :subGroups, :file_comment

    def initialize
      @elementId = ELEM_PROJECT_COMPONENT_GROUP
      @name = ""
      @file_comment

      @components = Array.new
      @subGroups = Array.new
    end
  end
end
