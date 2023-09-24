require "plugins_core/lang_typescript/class_base.rb"

##
# Class:: ClassInterface
#
module XCTETypescript
  class ClassInterface < ClassBase
    def initialize
      @name = "ts_interface"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
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

    def process_dependencies(cls, bld)
      super

      # Generate class variables
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|        
        if !Utils.instance.isPrimitive(var)
          Utils.instance.tryAddIncludeForVar(cls, var, "ts_interface")
        end
      }))
    end

    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.separate
      bld.startBlock("export interface " + getClassName(cls))

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.getVarDec(var))
      }))

      bld.endBlock
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassInterface.new)
