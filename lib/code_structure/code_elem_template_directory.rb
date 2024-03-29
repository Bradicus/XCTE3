##
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemTemplateDirectory < CodeElem
    attr_accessor :name, :path, :namespace, :isStatic, :dest, :languages

    def initialize(name = String.new, path = String.new, dest = String.new, baseNamespace = Array.new)
      @element_id = CodeStructure::CodeElemTypes::ELEM_TEMPLATE_DIRECTORY

      @name = name
      @path = path
      @dest = dest

      @languages = Array.new
      @isStatic = "static"
      @namespace = baseNamespace
    end
  end
end
