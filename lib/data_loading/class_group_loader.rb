##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class group information from an XML node

require "code_elem_project.rb"
require "code_structure/code_elem_build_var.rb"
require "data_loading/variable_loader"
require "data_loading/attribute_loader"
require "data_loading/namespace_util"
require "data_loading/class_ref_loader"
require "rexml/document"

module DataLoading
  class ClassGroupLoader
    def self.loadClassGroupFile(classGroup, path, pComponent)
      file = File.new(path)
      xmlString = file.read

      xmlDoc = REXML::Document.new xmlString
      classGroup.name = AttributeLoader.init(xmlDoc.root).names("name").get()
      classGroup.cFor = AttributeLoader.init(xmlDoc.root).names("variant").get()
      classGroup.data_node = xmlDoc.root
    end
  end
end
