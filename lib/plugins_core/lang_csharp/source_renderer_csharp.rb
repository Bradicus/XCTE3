##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders CSharp code

require 'source_renderer_brace_delim'

class SourceRendererCSharp < SourceRendererBraceDelim
  def initialize
    super

    @hangingBlockStart = false
  end

  def end_class(afterClose = '')
    end_block(afterClose)
  end
end
