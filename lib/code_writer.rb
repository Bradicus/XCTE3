##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information on the body file component of
# a project

module CodeStructure
  class CodeWriter
     attr_accessor :name, :path
    def initialize
      @lines=[]
      @name
      @path
    end
    
    def add(line)
      @lines []= line
    end
    
  end
end
