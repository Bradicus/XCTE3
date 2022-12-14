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
require "code_elem.rb"
require "code_elem_parent.rb"
require "code_elem_model.rb"
require "lang_file.rb"

module XCTEJava
  class ClassStandard < XCTEPlugin
    def initialize
      @name = "standard"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererJava.new

      javaFile = LangFile.new
      javaFile.lfName = Utils.instance.getStyledFileName(cls.getUName())
      javaFile.lfExtension = XCTEJava::Utils::getExtension("body")
      javaFile.lfContents = genJavaFileComment(cls, bld, cfg)
      javaFile.lfContents << genJavaFileContent(cls, bld, cfg)

      srcFiles << javaFile

      return srcFiles
    end

    def genJavaFileComment(cls, bld, cfg)
      bld.add("/**")
      bld.add("* @class " + cls.name)

      if (cfg.codeAuthor != nil)
        bld.add("* @author " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        bld.add("* " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.strip.size > 0
        bld.add("*\n* " + cfg.codeLicense)
      end

      bld.add("*")

      if (cls.description != nil)
        cls.description.each_line { |descLine|
          if descLine.strip.size > 0
            bld.add("* " << descLine.chomp)
          end
        }
      end

      bld.add("*/")
      bld.separate
    end

    # Returns the code for the header for this class
    def genJavaFileContent(cls, bld, cfg)
      for inc in cls.includesList
        bld.add('import "' + inc.path + inc.name + "\";")
      end

      bld.separate

      bld.startClass("public class " << cls.name)

      eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          bld.add("public static final int " + XCTEJava::Utils::getSizeConst(var) + " = " << var.arrayElemCount.to_s + ";")
        end
      }))

      if cls.hasAnArray
        bld.separate
      end

      # Generate class variables
      eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.add(XCTEJava::Utils::getVarDec(var))
      }))

      bld.separate

      render_functions()

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTEJava::ClassStandard.new)
