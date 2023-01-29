require "plugins_core/lang_typescript/class_base.rb"
require "derived_class_generator"

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

      editClass = DerivedClassGenerator.getEditClassRepresentation(cls)

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(editClass))
      bld.lfExtension = Utils.instance.getExtension("body")
      process_dependencies(editClass, bld)
      render_dependencies(editClass, bld)
      genFileComment(editClass, bld)
      genFileContent(editClass, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      super

      # Generate class variables
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.isPrimitive(var)
          varCls = Classes.findVarClass(var, "ts_interface")
          cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(var.getUType()), Utils.instance.getStyledClassName(var.getUType()))
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
