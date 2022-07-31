##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders source code
class SourceRenderer
  attr_accessor :lfName, :lfPath, :lfExtension, :lfContents, :indentLevel, :indentChars, :hangingFunctionStart, :hangingBlockStart,
                :customCode, :lines

  def initialize
    @lfName
    @lfPath = nil
    @lfExtension
    @indentLevel = 0
    @indentChars = "    "
    @lines = []
    @blockDelimOpen = "{"
    @blockDelimClose = "}"
    @hangingFunctionStart = false
    @hangingBlockStart = true

    # Ruby will use encoding specified when the file was opened, don't need this
    #if (OS.windows?)
    @lineEnding = "\n"
    #else
    #  @lineEnding = "\n"
    #end
  end

  def indent(count = 1)
    @indentLevel += count
  end

  def unindent(count = 1)
    @indentLevel -= count
  end

  def add(line = "")
    if (line.is_a?(Array))
      line.each { |item|
        self.add(item)
      }
    elsif (line.is_a?(String))
      if (line.length > 0)
        @lines.push(getIndent() << line)
      else
        @lines.push(getIndent() << line)
      end
    else
      raise TypeError, "invalid type " + line.inspect
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
    if (@lines.count > 0 && !@lines.last.strip.empty?)
      add
    end
  end

  def getIndent(extraIndent = 0)
    totalIndent = ""
    for i in 0..(@indentLevel + extraIndent - 1)
      totalIndent += @indentChars
    end

    return totalIndent
  end

  def getContents()
    outStr = ""

    @lines.each { |line|
      outStr << line << @lineEnding
    }
    return(outStr)
  end

  def endBlock(afterClose = "")
    unindent
    add(@blockDelimClose + afterClose)
  end

  def startFunction(functionDeclairation)
    startDelimedChunk(functionDeclairation, @hangingFunctionStart)
  end

  def endFunction()
    endBlock
  end

  def startClass(classDeclairation)
    startDelimedChunk(classDeclairation, @hangingFunctionStart)
  end

  def endClass(afterClose = "")
    unindent
    add(@blockDelimClose + afterClose)
  end

  def startBlock(statement)
    startDelimedChunk(statement, @hangingBlockStart)
  end

  def startDelimedChunk(statement = "", hanging = true)
    if (statement != "" && @blockDelimOpen.length > 0 && hanging)
      statement += " "
    end

    if (hanging)
      @lines.push(getIndent() + statement + @blockDelimOpen)
    else
      @lines.push(getIndent() + statement)
      @lines.push(getIndent() + @blockDelimOpen)
    end
    indent
  end
end
