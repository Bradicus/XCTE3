##
# Class:: LangGeneratorConfig
#

class LangGeneratorConfig
  attr_accessor :language, :tplPath, :dest, :namespaceList, :frameworks

  def initialize
    @language
    @tplPath
    @dest
    @namespaceList = Array.new
    @frameworks = Array.new
  end

  def usesFramework(fwk)
    for fw in frameworks
      if fw.name == fwk
        return true
      end
    end

    return false
  end
end
