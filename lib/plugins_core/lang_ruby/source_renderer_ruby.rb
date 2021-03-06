##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class renders C++ code

require 'source_renderer.rb'

class SourceRendererRuby < SourceRenderer

  def initialize()
    super

    @blockDelimOpen = ''
    @blockDelimClose = 'end'
    @indentChars = "  "
  end

  def midBlock(line)
    iadd(-1, line)
  end

end
    
