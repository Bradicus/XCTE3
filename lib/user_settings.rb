##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores user settings loaded from an XML file
 
class UserSettings
  attr_accessor :codeAuthor, :codeCompany, :codeLicense
  
  def initialize
    @codeAuthor
    @codeCompany
    @codeLicense
  end
  
  # Loads user settings from a file
  def load(fName)    
    file = File.new(fName)
    xmlDoc = REXML::Document.new file
    
    xmlDoc.elements["GLOBAL_PROFILE"].elements.each { |profElem|  
      #puts profElem
      if profElem.name == "AUTHOR"
        @codeAuthor = profElem.attributes["name"]
        @codeCompany = profElem.attributes["company"]
       # puts @codeAuthor
      elsif profElem.name == "DEFAULT_LICENSE"
        @codeLicense = profElem.attributes["text"]  
       # puts @codeLicense        
      end
    }
  end
end
