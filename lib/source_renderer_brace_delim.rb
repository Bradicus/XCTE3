##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders a block of code

require "source_renderer.rb"

class SourceRendererBraceDelim < SourceRenderer
  def initialize()
    super

    @blockDelimOpen = "{"
    @blockDelimClose = "}"

    @hangingFunctionBraces = false
    @hangingCodeBlockBraces = true
  end

  def midBlock(line)
    if (@hangingCodeBlockBraces)
      endBlock(" " + line + " " + @blockDelimOpen)
      indent
    else
      endBlock()
      startBlock(line)
    end
  end
end
