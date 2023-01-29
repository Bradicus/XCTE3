##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads project information form an XML file

require "code_elem_project.rb"
require "code_elem_build_var.rb"
require "rexml/document"

module DataProcessing
  class ProjectBuildVarLoader

    # Loads the set of build variables for a generator
    def self.loadBuildVars(gen, bvXml)
      bvXml.elements.each("build_var") { |bv|
        bVar = CodeElemBuildVar.new(bv.attributes["name"], bv.attributes["value"])
        gen.buildVars.push(bVar)
      }
    end
  end
end
