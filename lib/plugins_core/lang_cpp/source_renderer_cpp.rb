##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders C++ code

require "source_renderer_brace_delim"

class SourceRendererCpp < SourceRendererBraceDelim
  def initialize
    super
  end

  def genMultiComment(lines)
    add("/**")
    for line in lines
      add(" * " + line)
    end
    add(" */")
  end

  def endFunction(afterClose = "")
    end_block(afterClose)
    separate
  end

  def end_class(afterClose = "")
    end_block(";" + afterClose)
  end
end
