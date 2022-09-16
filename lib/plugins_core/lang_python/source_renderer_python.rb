##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class renders C++ code

require 'source_renderer.rb'

class SourceRendererPython < SourceRenderer

  def initialize()
    super

    @blockDelimOpen = ':'
    @blockDelimClose = ''
    @indentChars = "    "

    @hangingFunctionStart = true
    @hangingBlockStart = true
  end

  def midBlock(line)
    iadd(-1, line)
  end
  
  def startDelimedChunk(statement = "", hanging = true)

    if (hanging)
      @lines.push(getIndent() + statement + @blockDelimOpen)
    else
      @lines.push(getIndent() + statement)
      @lines.push(getIndent() + @blockDelimOpen);
    end
    indent
  end
end
   