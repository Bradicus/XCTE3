##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders php code

require "source_renderer_brace_delim.rb"
require "plugins_core/lang_typescript/utils"

module XCTETypescript
  class SourceRendererTypescript < SourceRendererBraceDelim
    def initialize()
      super

      @hangingFunctionStart = true
    end

    def start_function(funName, fun)
      params = []

      for param in fun.parameters.vars
        params.push Utils.instance.get_param_dec(param)
      end

      if funName != 'constructor'
        returnStr = Utils.instance.get_type_name(fun.returnValue)
      else
        returnStr = nil
      end

      start_function_paramed(
        Utils.instance.get_styled_function_name(funName), 
        params,
        returnStr)
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
end