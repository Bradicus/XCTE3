require "code_elem_namespace.rb"

##
# Class:: LangGeneratorConfig
#

class LangGeneratorConfig
  attr_accessor :language, :tplPath, :dest, :namespace, :xDeps, :buildVars, :headerComment, :ignore_namespace

  def initialize
    @language
    @tplPath
    @dest
    @namespace = CodeStructure::CodeElemNamespace.new
    @xDeps = Array.new
    @buildVars = Array.new
    @headerComment = ""
    @ignore_namespace = false
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
