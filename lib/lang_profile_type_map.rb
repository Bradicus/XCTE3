##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores mappings from XCTE generic types to language specific
# types

class LangProfileTypeMap
  attr_reader :genericType, :langType, :autoInclude, :tplType

  def initialize(genericType, langType, tplType, autoIncludePath, autoIncludeName, autoIncludeType)
    @genericType = genericType
    @langType = langType
    @tplType = tplType

    @autoInclude = CodeElemInclude.new(autoIncludePath, autoIncludeName, autoIncludeType)
  end
end
