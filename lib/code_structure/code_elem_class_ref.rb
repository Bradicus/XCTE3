##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require "code_structure/code_elem"
require "managers/name_compare"

module CodeStructure
  class CodeElemClassRef < CodeElem
    attr_accessor :namespace, :model_name, :plugin_name, :template_params

    def initialize(parentElem, _pComp)
      super(nil, parentElem)

      @namespace = CodeElemNamespace.new("")
      @model_name = nil
      @plugin_name = nil
      @template_params = []
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
