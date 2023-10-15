require "plugins_core/lang_css/utils.rb"
require "x_c_t_e_plugin.rb"

##
# Class:: ClassAngularListing
#
module XCTECss
  class ClassAngularListing < XCTEPlugin
    def initialize
      @name = "class_angular_listing"
      @language = "css"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls) + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECss::ClassAngularListing.new)
