##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores mappings from XCTE generic types to language specific 
# types

class LangProfileTypeMap  
  attr_accessor :genericType, :langType, :autoInclude
  
  def initialize(genericType, langType, autoIncludePath, autoIncludeName, autoIncludeType)
    @genericType = genericType
    @langType = langType

    @autoInclude = CodeElemInclude.new(autoIncludePath, autoIncludeName, autoIncludeType)
  end
end
