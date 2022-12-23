##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders php code

require "source_renderer_brace_delim.rb"

class SourceRendererTypescript < SourceRendererBraceDelim
  def initialize()
    super

    @hangingFunctionStart = true
  end
end
