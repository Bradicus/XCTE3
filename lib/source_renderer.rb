##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders source code
class SourceRenderer
  attr_accessor :lfName, :lfPath, :lfExtension, :indentLevel, :indentChars, :hangingFunctionStart, :hangingBlockStart,
                :customCode, :lines

  def initialize
    @lfPath = nil
    @indentLevel = 0
    @indentChars = '    '
    @lines = []
    @blockDelimOpen = '{'
    @blockDelimClose = '}'
    @hangingFunctionStart = false
    @hangingBlockStart = true
    @max_line_length = 100

    # Ruby will use encoding specified when the file was opened, don't need this
    # if (OS.windows?)
    @lineEnding = "\n"
    # else
    #  @lineEnding = "\n"
    # end
  end

  def indent(count = 1)
    @indentLevel += count
  end

  def unindent(count = 1)
    @indentLevel -= count
  end

  def add(line = '')
    if line.is_a?(Array)
      for item in line
        add(item)
      end
    elsif line.is_a?(String)
      if line.length > 0
        @lines.push(get_indent << line)
      else
        @lines.push(get_indent << line)
      end
    else
      raise TypeError, 'invalid type ' + line.inspect
    end
  end

  def iadd(count = 1, line)
    @lines.push(get_indent(count) << line)
  end

  def same_line(line)
    @lines.last << line
  end

  # if the last line isn't a blank line, add one for separation
  def separate
    return unless @lines.count > 0 && !@lines.last.strip.empty?

    add
  end

  # if the last line isn't a blank line, add one for separation
  def seperate_if(condition)
    return unless condition && @lines.count > 0 && !@lines.last.strip.empty?

    add
  end

  def get_indent(extraIndent = 0)
    totalIndent = ''
    for i in 0..(@indentLevel + extraIndent - 1)
      totalIndent += @indentChars
    end

    totalIndent
  end

  def getContents
    outStr = ''

    @lines.each do |line|
      outStr << line << @lineEnding
    end
    outStr
  end

  def end_block(afterClose = '')
    unindent

    if !@lines.last.strip.empty?
      add(@blockDelimClose + afterClose)
    else
      @lines.last.strip!
      same_line(get_indent + @blockDelimClose + afterClose)
    end

    separate
  end

  def start_function(functionDeclairation)
    start_delimed_chunk(functionDeclairation, @hangingFunctionStart)
  end

  def start_function_paramed(functionName, paramList, returnType = nil)
    if returnType.nil?
      returnStr = ''
    else
      returnStr = ': ' + returnType
    end
    
    oneLiner = paramList.join(', ')

    if (oneLiner.length + returnStr.length) > @max_line_length
      paramStr = "\n"

      (0..paramList.length - 1).each do |i|
        if i < paramList.length - 1
          paramStr += get_indent(2) + paramList[i] + ',' + "\n"
        else
          paramStr += get_indent(2) + paramList[i]
        end
      end

      start_delimed_chunk(functionName + '(' + paramStr + ')' + returnStr, @hangingFunctionStart)
    else
      start_delimed_chunk(functionName + '(' + oneLiner + ')' + returnStr, @hangingFunctionStart)
    end
  end

  def render_wrappable_list(line_start, item_list, separator)
    oneLiner = line_start + item_list.join(separator)
    if oneLiner.length <= @max_line_length
      add oneLiner
    else
      item_str = line_start + " "

      (0..item_list.length - 1).each do |i|
        if i < item_list.length - 1
          test_str = item_str + item_list[i] + separator
        else
          test_str = item_str + item_list[i]
        end

        if (test_str.length > @max_line_length)
          add item_str
          item_str = get_indent(2)
        else
          item_str = test_str
        end
      end

      if item_str.strip.length > 0
        add item_str
      end
    end
  end

  def endFunction
    end_block
  end

  def start_class(classDeclairation)
    start_delimed_chunk(classDeclairation, @hangingFunctionStart)
  end

  def end_class(afterClose = '')
    end_block(afterClose)
  end

  def start_block(statement)
    start_delimed_chunk(statement, @hangingBlockStart)
  end

  def start_delimed_chunk(statement = '', hanging = true)
    statement += ' ' if statement != '' && @blockDelimOpen.length > 0 && hanging

    if hanging
      @lines.push(get_indent + statement + @blockDelimOpen)
    else
      @lines.push(get_indent + statement)
      @lines.push(get_indent + @blockDelimOpen)
    end
    indent
  end
end
