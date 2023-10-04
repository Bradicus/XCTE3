require "plugins_core/lang_html/class_base"

##
# Class:: ClassAngularListing
#
module XCTEHtml
  class ClassAngularListing < ClassBase
    def initialize
      @name = "class_angular_listing"
      @language = "html"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls) + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      if (cls.model.findClassModel("class_angular_reactive_edit"))
        plug = XCTEPlugin::findClassPlugin("typescript", "class_angular_reactive_edit")

        bld.add('<button type="button" class="btn btn-primary" routerLink="/' +
                plug.get_full_route(cls, "edit") + '/0">New ' + cls.getUName() + "</button>")
      end

      tbl = TableUtil.instance.make_table(cls, "page", "item", true)

      bld.render_html(tbl)
    end
  end
end

XCTEPlugin::registerPlugin(XCTEHtml::ClassAngularListing.new)
