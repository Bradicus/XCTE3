##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders a block of code

require 'source_renderer'

class SourceRendererBraceDelim < SourceRenderer
  def initialize
    super

    @blockDelimOpen = '{'
    @blockDelimClose = '}'

    @hangingFunctionBraces = false
    @hangingCodeBlockBraces = true
  end

  def mid_block(line)
    if @hangingCodeBlockBraces
      end_block(' ' + line + ' ' + @blockDelimOpen)
      indent
    else
      end_block()
      start_block(line)
    end
  end
end
