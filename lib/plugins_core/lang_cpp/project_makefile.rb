##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates a project makefile

require 'plugins_core/lang_cpp/utils'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'
require 'code_elem'
require 'code_elem_project'
require 'lang_file'
require 'x_c_t_e_plugin'

class XCTECpp::ProjectMakefile < XCTEPlugin
  def initialize
    @name = 'makefile'
    @language = 'cpp'
    @category = XCTEPlugin::CAT_PROJECT
  end

  def gen_source_files(prj)
    srcFiles = []

    mFile = LangFile.new

    mFile.lfName = 'makefile'

    mFile.lfContents = String.new
    mFile.lfContents << 'OBJS = '
    mFile.lfContents << genObjList(prj.componentGroup)
    mFile.lfContents << "\n\n"
    mFile.lfContents << genLibPath(prj)
    mFile.lfContents << genLinkLibs(prj)
    mFile.lfContents << genObjPath(prj)
    mFile.lfContents << genIncludePath(prj)
    mFile.lfContents << genFlags(prj)

    if prj.buildType == CodeElem::ELEM_LIBRARY
      mFile.lfContents << 'lib' << prj.name << ".a: $(OBJS)\n"
      mFile.lfContents << "\t" << 'ar cr $(LIBPATH)lib' << prj.name << ".a $(OBJS)\n\n"
    else # Must be an application
      mFile.lfContents << prj.name << ": $(OBJS)\n"
      mFile.lfContents << "\t" << 'g++ -o bin/' << prj.name << " $(FLAGS) $(INCLUDES) $(OBJS) $(LIBPATH) $(LIBS)\n\n"
    end

    mFile.lfContents << genBuildList(prj.componentGroup)

    mFile.lfContents << "clean: \n"
    mFile.lfContents << "\t rm *.o\n"

    srcFiles << mFile

    return(srcFiles)
  end

  def genObjList(grpNode)
    listString = String.new

    for comp in grpNode.components
      if comp.elementId == CodeElem::ELEM_CLASS || comp.elementId == CodeElem::ELEM_BODY
        listString << comp.getObjFileName() << ' '
      end
    end

    for grp in grpNode.subGroups
      listString << genObjList(grp)
    end

    return(listString)
  end

  def genLibPath(prj)
    libPaths = String.new

    if prj.libraryDirs.length > 0
      libPaths << 'LIBPATH ='

      for libDir in prj.libraryDirs
        libPaths << ' -L' << libDir
      end

      libPaths << "\n\n"
    end

    return(libPaths)
  end

  def genLinkLibs(prj)
    libPaths = String.new

    if prj.linkLibs.length > 0
      libPaths << 'LIBS = '
      # libPaths << "\t-l" << prj.name << "\n"

      for lib in prj.linkLibs
        libPaths << ' -l' << lib
      end

      libPaths << "\n\n"
    end

    return(libPaths)
  end

  def genObjPath(_prj)
    return "OBJPATH = ../objs/\n\n"
  end

  def genIncludePath(prj)
    incPaths = String.new
    incPaths << 'INCLUDES = '

    for incDir in prj.includeDirs
      incPaths << ' -I' << incDir
    end

    incPaths << "\n\n"

    return(incPaths)
  end

  def genFlags(prj)
    flags = String.new

    for bType in prj.buildTypes
      if bType.buildType == 'default'
        flags = 'FLAGS = ' << bType.getBuildOpts('gcc')
      end
    end

    flags << "\n\n"

    return(flags)
  end

  def genBuildList(group)
    blString = String.new

    #   puts "[ProjectMakefile::genBuildList] processing group\n"

    for comp in group.components
      if !group.path.nil? && group.path.length > 0
        filePath = group.path + '/'
      else
        filePath = ''
      end

      if comp.elementId == CodeElem::ELEM_CLASS
        blString << comp.getObjFileName() << ': ' << filePath << comp.getCppFileName() << "\n"
        blString << "\tg++ $(FLAGS) $(INCLUDES) -c " << filePath << comp.getCppFileName() << "\n\n"
      elsif comp.elementId == CodeElem::ELEM_BODY
        blString << comp.getObjFileName() << ': ' << filePath << comp.getCppFileName() << "\n"
        blString << "\tg++ $(FLAGS) $(INCLUDES) -c " << filePath << comp.getCppFileName() << "\n\n"
      end

      #   puts "[ProjectMakefile::genBuildList] processing component " << comp.name << "\n"
    end

    for grp in group.subGroups
      blString << genBuildList(grp)
    end

    return(blString)
  end
end

XCTEPlugin.registerPlugin(XCTECpp::ProjectMakefile.new)
