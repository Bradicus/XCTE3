##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_java/utils.rb"
require "plugins_core/lang_java/x_c_t_e_java.rb"
require "plugins_core/lang_java/class_base.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "code_elem_model.rb"
require "lang_file.rb"

module XCTEJava
  class ClassFilterUtil < ClassBase
    def initialize
      @name = "class_filter_util"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererJava.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      process_dependencies(cls, bld)

      render_package_start(cls, bld)
      render_dependencies(cls, bld)

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addUse("org.springframework.data.domain.PageRequest")
      cls.addUse("org.springframework.data.domain.Sort")

      super
    end

    # Returns the code for the header for this class
    def genFileContent(cls, bld)
      cfg = UserSettings.instance

      bld.startClass("public class Filter")

      render_functions(cls, bld)

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTEJava::ClassFilterUtil.new)
