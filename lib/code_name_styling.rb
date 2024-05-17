# This class contains functions for styling variables by various standards

class CodeNameStyling
  def self.getStyled(name, styleName)
    case styleName
    when "CAMEL_CASE"
      return self.styleCamel(name)
    when "PASCAL_CASE"
      return self.stylePascal(name)
    when "UNDERSCORE_UPPER"
      return self.styleUnderscoreUpper(name)
    when "UNDERSCORE_LOWER"
      return self.styleUnderscoreLower(name)
    when "DASH_LOWER"
      return self.styleDashLower(name)
    when "LOWER_NOSPACE"
      return self.styleLowerNospace(name)
    else
      raise("Undefined style type: " + styleName.to_s)
    end
  end

  # Format name in pascal case
  def self.stylePascal(name)
    return self.get_capitalized_first(self.styleCamel(name))
  end

  # Format name in camel case
  def self.styleCamel(name)
    nameParts = name.split(" ")

    (1..nameParts.length - 1).each do |i|
      nameParts[i] = self.get_capitalized_first(nameParts[i])
    end

    return(nameParts.join(""))
  end

  # Format in uppercase with underscores
  def self.styleUnderscoreUpper(name)
    name = name.upcase
    nameParts = name.split(" ")
    return(nameParts.join("_"))
  end

  # Format in uppercase with underscores
  def self.styleUnderscoreLower(name)
    name = name.downcase
    nameParts = name.split(" ")
    return(nameParts.join("_"))
  end

  # Format in uppercase with dashes
  def self.styleDashLower(name)
    name = name.downcase
    nameParts = name.split(" ")
    return(nameParts.join("-"))
  end

  # All lower case with spaces removed
  def self.styleLowerNospace(name)
    name = name.downcase
    nameParts = name.split(" ")
    return(nameParts.join(""))
  end

  # Capitalizes the first letter of a string
  def self.get_capitalized_first(str)
    newStr = String.new
    newStr += str[0, 1].capitalize

    if (str.length > 1)
      newStr += str[1..str.length - 1]
    end

    return(newStr)
  end
end
