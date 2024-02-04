##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

## This class stores information for the parent code structure
# read in from an xml file

require 'code_elem_include'
require 'code_elem_use'
require 'code_structure/code_elem_namespace'
require 'managers/name_compare'
require 'code_structure/code_elem'

module CodeStructure
  class CodeElemClassRef < CodeStructure::CodeElem
    attr_accessor :namespaces, :model_name, :plugin_name

    def initialize(parentElem, _pComp)
      super(nil, parentElem)

      @namespaces = []
      @model_name = nil
      @plugin_name = nil
    end

    def matchesRef(ref)
      return NameCompare.matches(@model_name, ref.model_name) && NameCompare.matches(@plugin_name, ref.plugin_name)
    end

    def matches(other_model_name, other_plugin_name)
      # puts 'comparing ' +  @model_name + ' and ' + other_model_name
      # puts 'comparing ' +  @plugin_name + ' and ' + other_plugin_name
      return NameCompare.matches(@model_name, other_model_name) && NameCompare.matches(@plugin_name, other_plugin_name)
    end
  end
end
