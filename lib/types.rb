##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#

require "singleton"
require "type"

class Types
  attr_accessor :basic
  include Singleton

  def load(path)
    @basic = Array.new
    file = File.new path

    xmlDoc = REXML::Document.new file

    xmlDoc.elements.each("types/type") { |type|
      newType = Type.new

      newType.name = type.attributes["name"]
      newType.category = type.attributes["category"]

      @basic << newType
    }
  end

  def inCategory(var, category)
    varType = var.getUType().downcase()
    for btype in @basic
      if (varType == btype.name)
        return btype.category == category
      end
    end

    return false
  end
end
