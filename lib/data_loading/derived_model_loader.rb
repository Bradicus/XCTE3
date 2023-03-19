##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads derived model information form an XML node

require "code_elem_project.rb"
require "data_loading/attribute_util"
require "data_loading/namespace_util"
require "data_loading/variable_loader"
require "data_loading/class_loader"
require "rexml/document"
require "class_groups"
require "utils_base"

module DataLoading
  class DerivedModelLoader
    def self.loadModelFrom(model, derivedModel, xmlNode)
      modelType = deriveXml.attributes["model_type"]
      modelSet = deriveXml.attributes["model_set"]
      dName = deriveXml.attributes["name"]

      # If there is no model type, clone regular model
      if (modelType == nil)
        dm = model.copy()
        dm.name = dName
      else
        dPlug = XCTEPlugin::findDerivePlugin(modelType)

        if dPlug == nil
          Log.error("Unable to find plugin model type: " + modelType)
        else
          dPlug.get(dm, model, modelSet)

          deriveXml.elements.each("class_group_ref") { |xmlNode|
            cgName = xmlNode.attributes["name"]
            fGroup = xmlNode.attributes["feature_group"]
            cg = ClassGroups.get(cgName)

            if cg != nil
              cg.xmlElement.elements.each("gen_class") { |genCXML|
                loadClassGenNode(dm, genCXML, pComponent, fGroup)
              }
            else
              Log.error("Could not find requested class group " + cgName)
            end
          }

          deriveXml.elements.each("gen_class") { |genCXML|
            loadClassGenNode(dm, genCXML, pComponent, nil)
          }

          if (dm.name == nil)
            dm.name = dName
          end
        end

        deriveXml.elements.each("exclude") { |genCXML|
 #  BUtils.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var| }))
          }

        deriveXml.elements.each("exclude_group") { |genCXML|
 # loadClassGenNode(dm, genCXML, pComponent, nil)
          }

        model.derivedModels.push(dm)
      end
    end
  end
end
