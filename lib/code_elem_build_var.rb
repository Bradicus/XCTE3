##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the uses that get added to a class file

class CodeElemBuildVar
  attr_accessor :name, :value

  def initialize(name, value)
    @name = name
    @value = value
  end
end
