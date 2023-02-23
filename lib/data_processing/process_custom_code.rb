module DataProcessing
  class ProcessCustomCode
    def self.extractCustomCode(fName)
      customCode = nil
      foundStart = false
      foundEnd = false
      customCodeStart = "//+XCTE Custom Code Area"
      customCodeEnd = "//-XCTE Custom Code Area"

      File.open(fName).each_line do |line|
        if (!foundStart)
          if (line.include?(customCodeStart))
            foundStart = true
            customCode = ""
          end
        else
          if (!foundEnd)
            foundEnd = line.include?(customCodeEnd)
            if (line.include?(customCodeEnd))
              foundEnd = true
            else
              customCode += line
            end
          end
        end
      end

      return customCode
    end

    def self.insertCustomCode(customCode, srcRend)
      customCodeStart = "//+XCTE Custom Code Area"
      customCodeEnd = "//-XCTE Custom Code Area"

      finalLines = []
      started = false
      ended = false

      srcRend.lines.each_with_index { |line, index|
        if (!started && line.include?(customCodeStart))
          started = true
          finalLines << line
        elsif (started && !ended)
          if (line.include? customCodeEnd)
            ended = true
            finalLines << customCode + line
          end
        else
          finalLines << line
        end
      }

      return finalLines
    end
  end
end
