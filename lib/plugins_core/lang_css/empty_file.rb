require "plugins_core/lang_css/utils.rb"
require "x_c_t_e_plugin.rb"

##
# Class:: ClassAngularListing
#
module XCTECss
  class EmptyFile < XCTEPlugin
    def initialize
      @name = "empty_file"
      @language = "css"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls) + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, cfg, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECss::EmptyFile.new)