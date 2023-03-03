##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "code_elem_project.rb"
require "data_loading/attribute_util"
require "data_loading/namespace_util"
require "data_loading/variable_loader"
require "data_loading/class_loader"
require "rexml/document"
require "class_groups"

module DataLoading
  class ModelLoader
    def self.loadModelFile(model, fName, pComponent)
      file = File.new(fName)
      model.xmlFileName = fName
      model.lastModified = file.mtime
      xmlString = file.read
      xmlDoc = REXML::Document.new xmlString
      depthStack = Array.new
      model.name = xmlDoc.root.attributes["name"]
      model.xmlElement = xmlDoc.root

      xmlDoc.root.elements.each("derived") { |derived|
        model.derivedFrom = AttributeUtil.loadAttribute(derived, "from", pComponent)
        model.modelSet = AttributeUtil.loadAttribute(derived, "model_set", pComponent)
        if model.modelSet == nil
          Log.error("No model set for derived class in " + mdoel.name)
        end
      }

      xmlDoc.root.elements.each("description") { |desc|
        model.description = desc.text
      }
      xmlDoc.root.elements.each("var_group") { |vargXML|
        #puts "loading var group"
        newVGroup = CodeStructure::CodeElemVarGroup.new
        newVGroup.loadAttributes(vargXML)

        loadVarGroupNode(newVGroup, vargXML, pComponent)
        model.varGroup = newVGroup
      }
      xmlDoc.root.elements.each("gen_class") { |genCXML|
        loadClassGenNode(model, genCXML, pComponent)
      }

      # Load class groups
      xmlDoc.root.elements.each("class_group") { |nodeXml|
        cGroup = ClassGroups.get(nodeXml.attributes["name"])

        if cGroup != nil
          nodeXml.elements.each("gen_class") { |genCXML|
            loadClassGenNode(model, genCXML, pComponent)
          }
        end
      }

      # Create any derived models
      xmlDoc.root.elements.each("derive") { |deriveXml|
        dm = CodeStructure::CodeElemModel.new
        DerivedModelGenerator.getEditModelRepresentation(dm, model, deriveXml.attributes["model_set"])

        deriveXml.elements.each("class_group") { |xmlNode|
          cgName = xmlNode.attributes["name"]
          cg = ClassGroups.get(cgName)

          if cg != nil
            cg.xmlElement.elements.each("gen_class") { |genCXML|
              loadClassGenNode(dm, genCXML, pComponent)
            }
          else
            Log.error("Could not find requested class group " + cgName)
          end
        }

        deriveXml.elements.each("gen_class") { |genCXML|
          loadClassGenNode(dm, genCXML, pComponent)
        }

        model.derivedModels.push(dm)
      }
    end

    def self.loadClassGenNode(model, genCXML, pComponent)
      cls = CodeStructure::CodeElemClassGen.new(model, model, pComponent, true)
      ClassLoader.loadClass(pComponent, cls, genCXML)
      cls.xmlElement = genCXML
      Classes.list << cls
      model.classes << cls

      if cls.interfaceNamespace.hasItems?()
        intf = CodeStructure::CodeElemClassGen.new(cls, model, pComponent, true)
        intf.namespace = CodeStructure::CodeElemNamespace.new(cls.interfaceNamespace.get("."))
        intf.path = cls.interfacePath
        intf.functions = cls.functions
        intf.language = cls.language
        intf.plugName = "interface"
        intf.parentElem = cls
        intf.model = model
        Classes.list << intf
        model.classes << intf
      end

      if cls.testNamespace.hasItems?()
        intf = CodeStructure::CodeElemClassGen.new(cls, model, pComponent, true)
        intf.namespace = CodeStructure::CodeElemNamespace.new(cls.testNamespace.get("."))
        intf.path = cls.testPath
        intf.language = cls.language
        intf.plugName = "test_engine"
        intf.parentElem = cls
        intf.model = model
        Classes.list << intf
        model.classes << cls
      end
    end

    # Loads a group node from an XML template vargroup node
    def self.loadVarGroupNode(vgNode, vgXML, pComponent)
      if (vgXML.attributes["name"] != nil)
        vgNode.name = vgXML.attributes["name"]
      end

      #puts "[ElemClass::loadVarGroupNode] loading var node "

      for varElem in vgXML.elements
        if (varElem.name.downcase == "variable" || varElem.name.downcase == "var")
          VariableLoader.loadVariableNode(varElem, vgNode, pComponent)
        elsif (varElem.name == "var_group")
          newVG = CodeStructure::CodeElemVarGroup.new
          newVG.loadAttributes(varElem)
          loadVarGroupNode(newVG, varElem, pComponent)
          vgNode.varGroups << newVG
        elsif (varElem.name == "comment")
          loadCommentNode(varElem, vgNode.vars)
        elsif (varElem.name == "br")
          #          loadBRNode(varElem, vgNode.vars)
        end
      end
    end
  end
end
