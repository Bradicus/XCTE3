##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information on a file type for a language

class LangProfileFileType
  attr_accessor :fType, :fExtension
  
  def initialize(fType, fExtension)
    @fType = fType
    @fExtension = fExtension
  end
end
