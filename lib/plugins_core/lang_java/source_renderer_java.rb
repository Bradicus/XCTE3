##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders CSharp code

require "source_renderer_brace_delim.rb"

class SourceRendererJava < SourceRendererBraceDelim
  def initialize()
    super

    @hangingBlockStart = false
  end

  def endClass(afterClose = "")
    endBlock(afterClose)
  end
end
