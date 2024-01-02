require 'plugins_core/lang_typescript/class_base'

##
# Class:: ClassInterface
#
module XCTETypescript
  class ClassInterface < ClassBase
    def initialize
      @name = 'ts_interface'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def genSourceFiles(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.getExtension('body')
      process_dependencies(cls, bld)
      render_dependencies(cls, bld)
      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      super

      # Generate class variables
      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        Utils.instance.tryAddIncludeForVar(cls, var, 'standard') if !Utils.instance.is_primitive(var)
      }))
    end

    def genFileComment(cls, bld); end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.separate
      bld.startBlock('export interface ' + getClassName(cls))

      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.getVarDec(var))
      }))

      bld.endBlock
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassInterface.new)
