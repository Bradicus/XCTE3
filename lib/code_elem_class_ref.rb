##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

## This class stores information for the parent code structure
# read in from an xml file

require "code_elem.rb"
require "code_elem_include.rb"
require "code_elem_use.rb"
require "code_elem_namespace.rb"

module CodeStructure
  class CodeElemClassRef < CodeElem
    attr_accessor :namespaces, :className, :pluginName

    @namespaces = Array.new()
    @className = nil
    @pluginName = nil

    def initialize(parentElem, pComp)
      super(parentElem)
    end
  end
end
