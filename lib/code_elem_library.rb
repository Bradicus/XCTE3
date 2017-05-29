##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information on the library component of a project

module CodeStructure
  class CodeElemLibrary
     attr_accessor :name, :path

    def initialize(name, path)
      @elementId = CodeElem::ELEM_LIBRARY;

      if name != nil
        @name = name
      else
        @name = String.new
      end

      if path != nil
        @path = path
      else
        @path = String.new
      end
    end
    
  end
end
