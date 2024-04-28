##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders C++ code

require "source_renderer"

class SourceRendererSql < SourceRenderer
  def initialize
    super

    @blockDelimOpen = ""
    @blockDelimClose = ""
    @indentChars = "  "
  end

  def mid_block(line)
    iadd(-1, line)
  end

  def genMultiComment(lines)
    add("@*")
    for line in lines
      add(" * " + line)
    end
    add(" *@")
  end

  def endFunction(afterClose = "")
    end_block(afterClose)
    add
  end

  def end_class(afterClose = "")
    end_block("" + afterClose)
  end
end
