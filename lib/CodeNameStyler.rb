# This class contains functions for styling variables by various standards

class CodeNameStyler
  #
  def self.getCapitalizedFirststylePascal(name)
    return (self.getCapitalizedFirst(self.styleCamel(name))
  end
  
  #
  def self.styleCamel(name)
    var nameParts = name.split(" ")
    
    
  end
  
  # Capitalizes the first letter of a string
    def self.getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0,1].capitalize

      if (str.length > 1)
        newStr += str[1..str.length - 1]
      end
      
      return(newStr)
    end
end
