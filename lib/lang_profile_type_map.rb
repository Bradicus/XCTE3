##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores mappings from XCTE generic types to language specific 
# types

class LangProfileTypeMap  
  attr_accessor :genericType, :langType
  
  def initialize(genericType, langType)
    @genericType = genericType
    @langType = langType
  end
end
