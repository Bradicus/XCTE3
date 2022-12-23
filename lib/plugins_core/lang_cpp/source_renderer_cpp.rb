##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class renders C++ code

require 'source_renderer_brace_delim.rb'

class SourceRendererCpp < SourceRendererBraceDelim

  def initialize()
    super
  end

  def genMultiComment(lines)
    add('/**')
    for line in lines
      add(' * ' + line)
    end
    add(' */')
  end
  
  def endFunction(afterClose="")
    endBlock(afterClose)
    add
  end
  
  def endClass(afterClose="")
    endBlock(";" + afterClose)
  end
end
    
