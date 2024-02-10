##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores data for the project level

require 'code_structure/code_elem'
require "code_structure/code_elem_build_type.rb"
require "code_structure/code_elem_build_option.rb"

require "code_structure/code_elem_model.rb"
require "code_structure/code_elem_header.rb"
require "code_structure/code_elem_template_directory.rb"
require "code_structure/code_elem_project_component_group.rb"
require "external_dependency"
require "lang_generator_config.rb"

require "rexml/document"

module CodeStructure
  class ElemProject < CodeStructure::CodeElem
    attr_accessor :classType, :includes, :parentsList,
      :variableSection, :functionSection, :componentGroup, :buildType,
      :includeDirs, :libraryDirs, :linkLibs, :buildTypes, :dest, :langProfilePaths, :singleFile, :file_comment

    def initialize
      @element_id = CodeStructure::CodeElemTypes::ELEM_PROJECT
      @buildType
      @file_comment
      @templateFolders = Array.new
      @outputLanguages
      @type = String.new
      @componentGroup = CodeElemProjectComponentGroup.new
      @includeDirs = Array.new
      @libraryDirs = Array.new
      @linkLibs = Array.new
      @buildTypes = Array.new
      @langProfilePaths = Array.new
      @frameworks = Array.new
      @singleFile
    end
  end
end
