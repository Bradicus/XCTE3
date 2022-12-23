##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information on the body file component of
# a project

module CodeStructure
  class CodeElemBody < CodeElem
     attr_accessor :name, :path, :case

    def initialize
      @elementId = CodeElem::ELEM_BODY;
      @name
      @path
      @case
    end
    
    def getObjFileName
      lowName = @name
      lowName = lowName.downcase

      if (@case != nil && lowName != nil)
        return(lowName + ".o");
      else
        return(@name + ".o");
      end
    end

    def getCppFileName
      lowName = @name
      lowName = lowName.downcase

      if (@case != nil && lowName != nil)
        return(lowName + ".cpp");
      else
        return(@name + ".cpp");
      end
    end

  end
end
