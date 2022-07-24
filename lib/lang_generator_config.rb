##
# Class:: LangGeneratorConfig
#

class LangGeneratorConfig
  attr_accessor :language, :tplPath, :dest, :namespaceList

  def initialize
    @language
    @tplPath
    @dest
    @namespaceList = Array.new
  end
end
