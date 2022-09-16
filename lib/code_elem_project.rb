##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores data for the project level

require "code_elem.rb"
require "code_elem_model.rb"
require "code_elem_header.rb"
require "code_elem_template_directory.rb"
require "code_elem_build_type.rb"
require "code_elem_build_option.rb"
require "code_elem_project_component_group.rb"
require "lang_generator_config.rb"

require "rexml/document"

module CodeStructure
  class ElemProject < CodeElem
    attr_accessor :classType, :includes, :parentsList,
      :variableSection, :functionSection, :componentGroup, :buildType,
      :includeDirs, :libraryDirs, :linkLibs, :buildTypes, :dest, :langProfilePaths

    def initialize
      @elementId = CodeElem::ELEM_PROJECT
      @buildType
      @templateFolders = Array.new
      @outputLanguages
      @type = String.new
      @componentGroup = CodeElemProjectComponentGroup.new
      @includeDirs = Array.new
      @libraryDirs = Array.new
      @linkLibs = Array.new
      @buildTypes = Array.new
      @langProfilePaths = Array.new
    end

    # Move into a data loader some day
    def loadProject(fName)
      projFile = File.new(fName)

      xmlDoc = REXML::Document.new projFile

      @name = xmlDoc.root.attributes["name"]
      if @dest == nil
        @dest = "."
      end
      @buildType = xmlDoc.root.attributes["build_type"]

      @xmlElement = xmlDoc.root

      xmlDoc.elements.each("project") { |prj|
        loadComponentGroup(@componentGroup, prj)
      }
    end

    def loadComponentGroup(groupNode, xmlGroup)
      groupNode.name = xmlGroup.attributes["name"]

      if (xmlGroup.attributes["case"] != nil)
        groupNode.case = xmlGroup.attributes["case"]
      end
      if (xmlGroup.attributes["path"] != nil)
        groupNode.path = xmlGroup.attributes["path"]
      end

      xmlGroup.elements.each("DESCRIPTION") { |desc|
        groupNode.description = desc.text
      }
      # xmlGroup.elements.each("template_dir") { |tplDir|
      #   newTDir = CodeElemTemplateDirectory.new
      #   loadTemplateNode(newTDir, tplDir)
      #   groupNode.components << newTDir
      # }

      xmlGroup.elements.each("generate") { |tplDir|
        newTDir = LangGeneratorConfig.new
        loadGeneratorNode(newTDir, tplDir)
        groupNode.components << newTDir
      }

      xmlGroup.elements.each("custom_lang_profiles") { |langProf|
        @langProfilePaths << langProf.attributes["path"]
      }

      xmlGroup.elements.each("CLASS") { |cclass|
        newClass = CodeElemClassGen.new(this)
        loadClassNode(newClass, cclass)
        groupNode.components << newClass
      }
      xmlGroup.elements.each("HEADER") { |header|
        newHeader = CodeElemHeader.new
        loadHeaderNode(newHeader, header)
        groupNode.components << newHeader
      }
      xmlGroup.elements.each("BODY") { |body|
        newBody = CodeElemBody.new
        loadBodyNode(newBody, body)
        groupNode.components << newBody
      }
      xmlGroup.elements.each("CGROUP") { |cgroup|
        newCGroup = CodeElemProjectComponentGroup.new
        loadComponentGroup(newCGroup, cgroup)
        groupNode.subGroups << newCGroup

        # puts "Loaded component group: " << newCGroup.name << "\n"
      }

      xmlGroup.elements.each("INCLUDE_DIRS") { |inc_d|
        inc_d.elements.each("INC") { |lib_p|
          @includeDirs << lib_p.attributes["path"]
        }
      }
      xmlGroup.elements.each("LIBRARY_DIRS") { |lib_d|
        lib_d.elements.each("LPATH") { |inc_p|
          @libraryDirs << inc_p.attributes["path"]
        }
      }
      xmlGroup.elements.each("LINK_LIBS") { |lib_d|
        lib_d.elements.each("LLIB") { |inc_p|
          @linkLibs << inc_p.attributes["lib"]
        }
      }

      xmlGroup.elements.each("BUILD_TYPES") { |btypes|
        btypes.elements.each("BTYPE") { |btype|
          newBT = CodeElemBuildType.new
          newBT.buildType = btype.attributes["btype"]
          loadBuildTypeNode(newBT, btype)
          buildTypes << newBT
        }
      }
    end

    def loadClassNode(cNode, cNodeXML)
      cNode.name = cNodeXML.attributes["name"]
      cNode.case = cNodeXML.attributes["case"]
    end

    def loadHeaderNode(hNode, hNodeXML)
      hNode.name = hNodeXML.attributes["name"]
      hNode.case = hNodeXML.attributes["case"]
    end

    def loadBodyNode(bNode, bNodeXML)
      bNode.name = bNodeXML.attributes["name"]
      bNode.case = bNodeXML.attributes["case"]
    end

    def loadTemplateNode(tNode, tNodeXml)
      tNode.path = tNodeXml.attributes["path"]
      tNode.dest = tNodeXml.attributes["dest"]

      if tNode.dest == nil
        tNode.dest = "."
      end

      tNode.isStatic = (tNodeXml.attributes["static_code"] == true)
      tNode.languages = tNodeXml.attributes["languages"].split(" ")

      if (tNodeXml.attributes["base_namespace"] != nil)
        tNode.namespaceList = tNodeXml.attributes["base_namespace"].split(".")
      end
      puts "template node loaded with path"
    end

    def loadGeneratorNode(tNode, tNodeXml)
      tNode.language = tNodeXml.attributes["language"]
      tNode.tplPath = tNodeXml.attributes["tpl_path"]
      tNode.dest = tNodeXml.attributes["dest"]

      if tNode.dest == nil
        tNode.dest = "."
      end

      if (tNodeXml.attributes["base_namespace"] != nil)
        tNode.namespaceList = tNodeXml.attributes["base_namespace"].split(".")
      end
      puts "template node loaded with path"
    end

    def loadBuildTypeNode(btNode, btNodeXML)
      btNodeXML.elements.each("BOPTION") { |bopt|
        newOpt = CodeElemBuildOption.new(bopt.attributes["otype"], bopt.attributes["ovalue"])
        btNode.buildOptions << newOpt
      }
    end
  end
end
