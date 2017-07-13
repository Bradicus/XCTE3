# This class contains functions for styling variables by various standards

class CodeNameStyling
  # Format name in pascal case
  def self.stylePascal(name)
    return self.getCapitalizedFirst(self.styleCamel(name))
  end

  # Format name in camel case
  def self.styleCamel(name)
    nameParts = name.split(" ")
    first = true

    for namePart in nameParts
      if (!first)
        namePart = self.getCapitalizedFirst(namePart)
      end

      first = false
    end

    return(nameParts.join(''))
  end

  # Format in uppercase with underscores
  def self.styleUnderscoreUpper(name)
    nameParts = name.split(" ")
    first = true

    for namePart in nameParts
      if (!first)
        namePart = namePart.upcase
      end
    end

    return(nameParts.join('_'))
  end

  # Capitalizes the first letter of a string
  def self.getCapitalizedFirst(str)
    newStr = String.new
    newStr += str[0, 1].capitalize

    if (str.length > 1)
      newStr += str[1..str.length - 1]
    end

    return(newStr)
  end
end
