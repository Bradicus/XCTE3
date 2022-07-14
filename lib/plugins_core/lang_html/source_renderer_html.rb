##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders php code

require "source_renderer.rb"

class SourceRendererHtml < SourceRenderer
  def initialize()
    super

    @blockDelimOpen = ""
    @blockDelimClose = ""
  end
end
