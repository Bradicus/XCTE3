##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders a block of code 

require 'source_renderer.rb'

class SourceRendererBraceDelim < SourceRenderer  
  def initialize()
    super
    
    @blockDelimOpen = '{'
    @blockDelimClose = '}'
    
    @hangingFunctionBraces = false
    @hangingCodeBlockBraces = true
  end
end
