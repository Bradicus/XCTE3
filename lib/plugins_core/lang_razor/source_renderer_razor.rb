##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class renders C++ code

require 'source_renderer.rb'

class SourceRendererRazor < SourceRenderer

  def initialize()
    super

    @blockDelimOpen = ''
    @blockDelimClose = ''
    @indentChars = "  "
  end

  def midBlock(line)
    iadd(-1, line)
  end

  def genMultiComment(lines)
    add('@*')
    for line in lines
      add(' * ' + line)
    end
    add(' *@')
  end
  
  def endFunction(afterClose="")
    endBlock(afterClose)
    add
  end
  
  def endClass(afterClose="")
    endBlock("" + afterClose)
  end
end
    
