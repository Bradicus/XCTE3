##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders Java code

require "plugins_core/lang_java/utils.rb"
require "source_renderer_brace_delim.rb"

class SourceRendererJava < SourceRendererBraceDelim
  def initialize()
    super

    @hangingBlockStart = true
    @hangingFunctionBraces = true
    @hangingFunctionStart = true
  end

  def get_utils()
    return XCTEJava::Utils.instance
  end

  def endClass(afterClose = "")
    endBlock(afterClose)
  end

  def render_function_declairation(fun)
    paramStrings = []

    for pVar in fun.parameters.vars
      paramStrings.push(get_utils().getParamDec(pVar))
    end
    
    typeName = get_utils().getTypeName(fun.returnValue)

    if (typeName == 'void')
      add typeName + ' '
    else
      add get_utils().getStyledClassName(typeName) + ' '
    end

    sameLine get_utils().getStyledFunctionName(fun.name) + "(" + paramStrings.join(', ') + ");"
  end

  def render_function_call(assignTo, callFrom, fun, paramStrings)
  
    if assignTo == nil
      assignment = ""
    else
      assignment = assignTo + " = "
    end

    add assignment + callFrom + "." + get_utils().getStyledFunctionName(fun.name) + "(" + paramStrings.join(', ') + ");"
  end

end
