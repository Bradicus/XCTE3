##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information and contents for a file generated by XCTE
class LangFile
  attr_accessor :lfName, :lfExtension, :lfContents, :indentLevel, :indentChars
  def initialize
    @lfName
    @lfExtension
    @indentLevel = 0
    @indentChars = "    "
    @lines=[]
    @blockDelimOpen = '{'
    @blockDelimClose = '}'
  end

  def indent(count = 1)
    @indentLevel += count
  end

  def unindent(count = 1)
    @indentLevel -= count
  end

  def add(line = "")
    @lines.push(getIndent() << line)
  end

  def iadd(count = 1, line)
    @lines.push(getIndent(count) << line)
  end

  def sameLine(line)
    @lines.last << getIndent() + line
  end

  def getIndent(extraIndent = 0)
    totalIndent = ""
    for i in 0..(indentLevel + extraIndent - 1)
      totalIndent += @indentChars
    end

    return totalIndent
  end

  def getContents()
    outStr = '';

    @lines.each { |line|
      outStr << line << "\n"
    }
    return(outStr)
  end

end
