##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates a cmake lists files(CMakeLists.txt)

require 'plugins_core/lang_cpp/utils'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'
require 'code_elem'
require 'code_elem_project'
require 'lang_file'
require 'x_c_t_e_plugin'

class XCTECpp::ProjectCMakeLists < XCTEPlugin
  def initialize
    @name = 'cmake'
    @language = 'cpp'
    @category = XCTEPlugin::CAT_PROJECT
  end

  def gen_source_files(prj)
    srcFiles = []

    mFile = LangFile.new

    mFile.lfName = 'CMakeLists.txt'

    mFile.lfContents = String.new
    mFile.lfContents << 'PROJECT(' << prj.name << ")\n\n"

    mFile.lfContents << "SET(SRC_BODY_FILES\n"
    mFile.lfContents << genBodyList(prj.componentGroup)
    mFile.lfContents << ")\n\n"

    mFile.lfContents << "SET(SRC_HEADER_FILES\n"
    mFile.lfContents << genHeaderList(prj.componentGroup)
    mFile.lfContents << ")\n\n"

    mFile.lfContents << genLibPath(prj)
    mFile.lfContents << genIncludePath(prj)
    mFile.lfContents << genLinkLibs(prj)
    mFile.lfContents << genFlags(prj)
    mFile.lfContents << "\n"

    if prj.buildType == CodeElem::ELEM_LIBRARY
      mFile.lfContents << "SET(LIBRARY_OUTPUT_PATH ../linuxlib)\n"
      mFile.lfContents << 'ADD_LIBRARY(' << prj.name << " STATIC ${SRC_BODY_FILES})\n"
    else
      mFile.lfContents << 'ADD_EXECUTABLE(' << prj.name << " ${SRC_BODY_FILES})\n"
    end

    srcFiles << mFile

    return(srcFiles)
  end

  def genBodyList(grpNode)
    listString = String.new

    if !grpNode.path.nil? && grpNode.path.length > 0
      filePath = grpNode.path + '/'
    else
      filePath = ''
    end

    for comp in grpNode.components
      if comp.elementId == CodeElem::ELEM_CLASS || comp.elementId == CodeElem::ELEM_BODY
        listString << "\t" << filePath << comp.getCppFileName() << "\n"
      end
    end

    listString << "\n"

    for grp in grpNode.subGroups
      listString << genBodyList(grp)
    end

    return(listString)
  end

  def genHeaderList(grpNode)
    listString = String.new

    if !grpNode.path.nil? && grpNode.path.length > 0
      filePath = grpNode.path + '/'
    else
      filePath = ''
    end

    for comp in grpNode.components
      if comp.elementId == CodeElem::ELEM_CLASS || comp.elementId == CodeElem::ELEM_HEADER
        listString << "\t" << filePath << comp.getHeaderFileName() << "\n"
      end
    end

    listString << "\n"

    for grp in grpNode.subGroups
      listString << genHeaderList(grp)
    end

    return(listString)
  end

  def genLibPath(prj)
    libPaths = String.new

    if prj.libraryDirs.length > 0
      libPaths << "LINK_DIRECTORIES(\n"

      for libDir in prj.libraryDirs
        libPaths << "\t" << libDir << "\n"
      end

      libPaths << ")\n\n"
    end

    return(libPaths)
  end

  def genIncludePath(prj)
    incPaths = String.new
    incPaths << "INCLUDE_DIRECTORIES(\n"

    for incDir in prj.includeDirs
      incPaths << "\t" << incDir << "\n"
    end

    incPaths << ")\n\n"

    return(incPaths)
  end

  def genLinkLibs(prj)
    libPaths = String.new

    if prj.linkLibs.length > 0
      libPaths << "SET(CUSTOM_LINK_ENTRIES\n"
      # libPaths << "\t-l" << prj.name << "\n"

      for lib in prj.linkLibs
        libPaths << "\t-l" << lib << "\n"
      end

      libPaths << ")\n\n"
    end

    return(libPaths)
  end

  def genFlags(prj)
    flags = String.new

    for bType in prj.buildTypes
      if bType.buildType == 'debug'
        flags << 'SET(CMAKE_CXX_FLAGS_DEBUG "'
        flags << bType.getBuildOpts('gcc')
        if prj.linkLibs.length > 0
          flags << '$(CUSTOM_LINK_ENTRIES)'
        end
        flags << "\")\n"
      elsif bType.buildType == 'release'
        flags << 'SET(CMAKE_CXX_FLAGS_RELEASE "'
        flags << bType.getBuildOpts('gcc')
        if prj.linkLibs.length > 0
          flags << '$(CUSTOM_LINK_ENTRIES)'
        end
        flags << "\")\n"
      else
        flags << 'SET(CMAKE_CXX_FLAGS "'
        flags << bType.getBuildOpts('gcc')
        if prj.linkLibs.length > 0
          flags << '$(CUSTOM_LINK_ENTRIES)'
        end
        flags << "\")\n"
      end
    end

    return(flags)
  end
end

XCTEPlugin.registerPlugin(XCTECpp::ProjectCMakeLists.new)
