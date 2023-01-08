require "code_elem_namespace.rb"

##
# Class:: LangGeneratorConfig
#

class LangGeneratorConfig
  attr_accessor :language, :tplPath, :dest, :namespace, :xDeps

  def initialize
    @language
    @tplPath
    @dest
    @namespace = CodeStructure::CodeElemNamespace.new
    @xDeps = Array.new
  end

  def usesExternalDependency(xdep)
    for fw in xDeps
      if fw.name == xdep
        return true
      end
    end

    return false
  end
end
