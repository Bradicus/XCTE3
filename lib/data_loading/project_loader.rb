##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads project information form an XML file

require 'code_elem_project'
require 'data_loading/project_build_var_loader'
require 'rexml/document'

module DataLoading
  class ProjectLoader
    # Load project from a file
    def self.loadProject(project, fName)
      projFile = File.new(fName)

      xmlDoc = REXML::Document.new projFile

      project.name = xmlDoc.root.attributes['name']
      if project.dest.nil?
        project.dest = '.'
      end
      project.buildType = xmlDoc.root.attributes['build_type']

      project.xmlElement = xmlDoc.root      

      xmlDoc.elements.each('project') do |prj|
        prj.elements.each('file_comment') do |desc|
          project.file_comment = desc.text
        end

        loadComponentGroup(project, project.componentGroup, prj)
      end
    end

    def self.loadComponentGroup(project, groupNode, xmlGroup)
      groupNode.name = xmlGroup.attributes['name']

      if !xmlGroup.attributes['case'].nil?
        groupNode.case = xmlGroup.attributes['case']
      end
      if !xmlGroup.attributes['path'].nil?
        groupNode.path = xmlGroup.attributes['path']
      end

      xmlGroup.elements.each('DESCRIPTION') do |desc|
        groupNode.description = desc.text
      end

      

      # xmlGroup.elements.each("template_dir") { |tplDir|
      #   newTDir = CodeElemTemplateDirectory.new
      #   loadTemplateNode(newTDir, tplDir)
      #   groupNode.components << newTDir
      # }

      xmlGroup.elements.each('generate') do |tplDir|
        newTDir = LangGeneratorConfig.new
        loadGeneratorNode(newTDir, tplDir)
        groupNode.components << newTDir
      end

      xmlGroup.elements.each('custom_lang_profiles') do |langProf|
        project.langProfilePaths << langProf.attributes['path']
      end

      xmlGroup.elements.each('CLASS') do |cclass|
        newClass = CodeElemClassSpec.new(this)
        loadClassNode(newClass, cclass)
        groupNode.components << newClass
      end
      xmlGroup.elements.each('HEADER') do |header|
        newHeader = CodeElemHeader.new
        loadHeaderNode(newHeader, header)
        groupNode.components << newHeader
      end
      xmlGroup.elements.each('BODY') do |body|
        newBody = CodeElemBody.new
        loadBodyNode(newBody, body)
        groupNode.components << newBody
      end
      xmlGroup.elements.each('CGROUP') do |cgroup|
        newCGroup = CodeElemProjectComponentGroup.new
        loadComponentGroup(newCGroup, cgroup)
        groupNode.subGroups << newCGroup

        # puts "Loaded component group: " << newCGroup.name << "\n"
      end

      #   xmlGroup.elements.each("INCLUDE_DIRS") { |inc_d|
      #     inc_d.elements.each("INC") { |lib_p|
      #       @includeDirs << lib_p.attributes["path"]
      #     }
      #   }
      #   xmlGroup.elements.each("LIBRARY_DIRS") { |lib_d|
      #     lib_d.elements.each("LPATH") { |inc_p|
      #       @libraryDirs << inc_p.attributes["path"]
      #     }
      #   }
      #   xmlGroup.elements.each("LINK_LIBS") { |lib_d|
      #     lib_d.elements.each("LLIB") { |inc_p|
      #       @linkLibs << inc_p.attributes["lib"]
      #     }
      #   }

      #   xmlGroup.elements.each("BUILD_TYPES") { |btypes|
      #     btypes.elements.each("BTYPE") { |btype|
      #       newBT = CodeElemBuildType.new
      #       newBT.buildType = btype.attributes["btype"]
      #       loadBuildTypeNode(newBT, btype)
      #       buildTypes << newBT
      #     }
      #   }

      return project
    end

    def self.loadClassNode(cNode, cNodeXML)
      cNode.name = cNodeXML.attributes['name']
      cNode.case = cNodeXML.attributes['case']
    end

    def self.loadHeaderNode(hNode, hNodeXML)
      hNode.name = hNodeXML.attributes['name']
      hNode.case = hNodeXML.attributes['case']
    end

    def self.loadBodyNode(bNode, bNodeXML)
      bNode.name = bNodeXML.attributes['name']
      bNode.case = bNodeXML.attributes['case']
    end

    def self.loadExternalDependency(fw, fwXML)
      fw.name = fwXML.attributes['name']
      fw.version = fwXML.attributes['version']
      fw.minVer = fwXML.attributes['minVer']
      fw.maxVer = fwXML.attributes['maxVer']
    end

    def self.loadTemplateNode(tNode, tNodeXml)
      tNode.path = tNodeXml.attributes['path']
      tNode.dest = tNodeXml.attributes['dest']

      if tNode.dest.nil?
        tNode.dest = '.'
      end

      tNode.isStatic = (tNodeXml.attributes['static_code'] == true)
      tNode.languages = tNodeXml.attributes['languages'].split(' ')

      if !tNodeXml.attributes['base_namespace'].nil?
        tNode.namespace = CodeElemNamespace.new(tNodeXml.attributes['base_namespace'])
      end
      puts 'template node loaded with path'
    end

    def self.loadGeneratorNode(tNode, tNodeXml)
      tNode.language = tNodeXml.attributes['language']
      tNode.tplPath = tNodeXml.attributes['tpl_path']
      tNode.dest = tNodeXml.attributes['dest']
      tNode.ignore_namespace = tNodeXml.attributes['ignore_namespace'] == 'true'

      tNodeXml.elements.each('file_comment') do |fwNode|
        tNode.file_comment = fwNode.text.strip!()
      end

      if tNode.dest.nil?
        tNode.dest = '.'
      end

      if !tNodeXml.attributes['base_namespace'].nil?
        tNode.namespace = CodeElemNamespace.new(tNodeXml.attributes['base_namespace'])
      end

      tNodeXml.elements.each('xdep') do |fwNode|
        fw = ExternalDependency.new
        loadExternalDependency(fw, fwNode)
        tNode.xDeps << fw
      end

      tNodeXml.elements.each('build_vars') do |bvsNode|
        ProjectBuildVarLoader.loadBuildVars(tNode, bvsNode)
      end
    end

    def self.loadBuildTypeNode(btNode, btNodeXML)
      btNodeXML.elements.each('BOPTION') do |bopt|
        newOpt = CodeElemBuildOption.new(bopt.attributes['otype'], bopt.attributes['ovalue'])
        btNode.buildOptions << newOpt
      end
    end
  end
end
