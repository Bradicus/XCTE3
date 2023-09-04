##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_typescript/utils.rb"
require "plugins_core/lang_typescript/x_c_t_e_Typescript.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "code_elem_model.rb"
require "lang_file.rb"

module XCTETypescript
  class ClassFilteredDatasetReqTpl < ClassBase
    def initialize
      @name = "class_filtered_dataset_req_tpl"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " req tpl"
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)
      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def genFileComment(cls, bld)
      cfg = UserSettings.instance
      headerString = String.new

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

      bld.add("* ")

      if (cls.description != nil)
        cls.description.each_line { |descLine|
          if descLine.strip.size > 0
            bld.add("* " << descLine.chomp)
          end
        }
      end

      bld.add("*/")

      return(headerString)
    end

    # Returns the code for the header for this class
    def genFileContent(cls, bld)
      headerString = String.new

      bld.separate

      for inc in cls.includes
        bld.add("require '" + inc.path + inc.name + "." + Utils.instance.getExtension("body") + "'")
      end

      bld.separate
      bld.startClass("export class " + getClassName(cls) + "<T>")

      model = InternalClassModelManager.findModel("page request")

      # Generate class variables
      eachVar(uevParams().wCls(model).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.getVarDec(var))
      }))

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassFilteredDatasetReqTpl.new)
