require "code_elem_namespace.rb"

##
# Class:: LangGeneratorConfig
#

class LangGeneratorConfig
  attr_accessor :language, :tplPath, :dest, :namespace, :frameworks

  def initialize
    @language
    @tplPath
    @dest
    @namespace = CodeStructure::CodeElemNamespace.new
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
