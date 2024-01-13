##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders C++ code

require 'source_renderer'

class SourceRendererRuby < SourceRenderer
  def initialize
    super

    @blockDelimOpen = ''
    @blockDelimClose = 'end'
    @indentChars = '  '
    @hangingFunctionStart = true
  end

  def mid_block(line)
    iadd(-1, line)
  end
end
