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
        @lines.push(getIndent << line)
      else
        @lines.push(getIndent << line)
      end
    else
      raise TypeError, 'invalid type ' + line.inspect
    end
  end

  def iadd(count = 1, line)
    @lines.push(getIndent(count) << line)
  end

  def sameLine(line)
    @lines.last << line
  end

  # if the last line isn't a blank line, add one for separation
  def separate
    return unless @lines.count > 0 && !@lines.last.strip.empty?

    add
  end

  # if the last line isn't a blank line, add one for separation
  def separateIf(condition)
    return unless condition && @lines.count > 0 && !@lines.last.strip.empty?

    add
  end

  def getIndent(extraIndent = 0)
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

  def endBlock(afterClose = '')
    unindent

    if !@lines.last.strip.empty?
      add(@blockDelimClose + afterClose)
    else
      @lines.last.strip!
      sameLine(getIndent + @blockDelimClose + afterClose)
    end

    separate
  end

  def startFunction(functionDeclairation)
    startDelimedChunk(functionDeclairation, @hangingFunctionStart)
  end

  def startFunctionParamed(functionName, paramList)
    oneLiner = paramList.join(', ')
    if oneLiner.length > 100
      paramStr = "\n"

      (0..paramList.length - 1).each do |i|
        if i < paramList.length - 1
          paramStr += getIndent(2) + paramList[i] + ',' + "\n"
        else
          paramStr += getIndent(2) + paramList[i]
        end
      end

      startDelimedChunk(functionName + '(' + paramStr + ')', @hangingFunctionStart)
    else
      startDelimedChunk(functionName + '(' + oneLiner + ')', @hangingFunctionStart)
    end
  end

  def endFunction
    endBlock
  end

  def startClass(classDeclairation)
    startDelimedChunk(classDeclairation, @hangingFunctionStart)
  end

  def endClass(afterClose = '')
    endBlock(afterClose)
  end

  def startBlock(statement)
    startDelimedChunk(statement, @hangingBlockStart)
  end

  def startDelimedChunk(statement = '', hanging = true)
    statement += ' ' if statement != '' && @blockDelimOpen.length > 0 && hanging

    if hanging
      @lines.push(getIndent + statement + @blockDelimOpen)
    else
      @lines.push(getIndent + statement)
      @lines.push(getIndent + @blockDelimOpen)
    end
    indent
  end
end
