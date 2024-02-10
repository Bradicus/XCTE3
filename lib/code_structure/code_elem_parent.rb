##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory

class CodeElemParent
  attr_accessor :name, :visibility
  
  def initialize(name, visibility)
    @element_id = CodeStructure::CodeElemTypes::ELEM_PARENT

    if name != nil
      @name = name
    else
      @name = "ERROR no parent name!!!"
    end
    
    if visibility != nil
      @visibility = visibility   
    else
      @visibility = "private"
    end
  end
end
