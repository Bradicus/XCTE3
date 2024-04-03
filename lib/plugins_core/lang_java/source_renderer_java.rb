##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders Java code

require 'plugins_core/lang_java/utils'
require 'source_renderer_brace_delim'

class SourceRendererJava < SourceRendererBraceDelim
  def initialize
    super

    @hangingBlockStart = true
    @hangingFunctionBraces = true
    @hangingFunctionStart = true
  end

  def get_utils
    return XCTEJava::Utils.instance
  end

  def end_class(afterClose = '')
    end_block(afterClose)
  end

  def render_function_declairation(fun)
    paramStrings = []

    for annotation in fun.annotations
      add annotation
    end

    for pVar in fun.parameters.vars
      paramStrings.push(get_utils.get_param_dec(pVar))
    end

    typeName = get_utils.get_type_name(fun.returnValue)

    if typeName == 'void'
      add typeName + ' '
    else
      add get_utils.style_as_class(typeName) + ' '
    end

    same_line get_utils.style_as_function(fun.name) + '(' + paramStrings.join(', ') + ');'
  end

  def render_function_call(assignTo, callFrom, fun, paramStrings)
    if assignTo.nil?
      assignment = ''
    else
      assignment = assignTo + ' = '
    end

    add assignment + callFrom + '.' + get_utils.style_as_function(fun.name) + '(' + paramStrings.join(', ') + ');'
  end
end
