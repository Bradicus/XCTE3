# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemBody < CodeStructure::CodeElem
    attr_accessor :name, :path, :case

    def initialize
      super

      @element_id = CodeStructure::CodeElemTypes::ELEM_BODY
    end

    def getObjFileName
      lowName = @name
      lowName = lowName.downcase

      if !@case.nil? && !lowName.nil?
        return(lowName + '.o')
      else
        return(@name + '.o')
      end
    end

    def getCppFileName
      lowName = @name
      lowName = lowName.downcase

      if !@case.nil? && !lowName.nil?
        return(lowName + '.cpp')
      else
        return(@name + '.cpp')
      end
    end
  end
end
