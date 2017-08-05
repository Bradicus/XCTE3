##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class renders C++ code

require 'source_renderer_brace_delim.rb'

class SourceRendererCpp < SourceRendererBraceDelim

  def initialize()
    super
  end
  
  def endClass(afterClose="")
    endBlock(";" + afterClose)
  end
end
    