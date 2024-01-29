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

  def comment_file(file_comm)
    add '/* '

    fc = file_comm.strip

    for line in fc.split("\n")
      add  '* ' + line.rstrip
    end
    add '*/'
  end
end
