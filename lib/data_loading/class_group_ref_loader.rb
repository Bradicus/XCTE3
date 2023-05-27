##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class group information from an XML node

require "code_elem_project.rb"
require "code_elem_build_var.rb"
require "data_loading/attribute_loader"
require "data_loading/class_ref_loader"
require "rexml/document"

module DataLoading
  class ClassGroupRefLoader
    def self.loadClassGroupRef(cgRef, xmlNode)
      if xmlNode != nil
        cgRef.name = AttributeLoader.init(xmlNode).names("name").get()
        cgRef.for = AttributeLoader.init(xmlNode).names("for").get()
        cgRef.featureGroup = AttributeLoader.init(xmlNode).names("feature_group").get()
        cgRef.xmlElement = xmlNode
      end
    end
  end
end