##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders C++ code

require 'source_renderer'

class SourceRendererPython < SourceRenderer
  def initialize
    super

    @blockDelimOpen = ':'
    @blockDelimClose = ''
    @indentChars = '    '

    @hangingFunctionStart = true
    @hangingBlockStart = true
  end

  def mid_block(line)
    iadd(-1, line)
  end

  def start_delimed_chunk(statement = '', hanging = true)
    if hanging
      @lines.push(get_indent() + statement + @blockDelimOpen)
    else
      @lines.push(get_indent() + statement)
      @lines.push(get_indent() + @blockDelimOpen)
    end
    indent
  end
end
