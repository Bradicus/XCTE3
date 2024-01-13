require 'plugins_core/lang_css/utils'
require 'x_c_t_e_plugin'

##
# Class:: ClassAngularListing
#
module XCTECss
  class ClassAngularReactiveView < XCTEPlugin
    def initialize
      @name = 'class_angular_reactive_view'
      @language = 'css'
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      Utils.instance.get_styled_class_name(get_unformatted_class_name(cls))
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls) + '.component')
      bld.lfExtension = Utils.instance.get_extension('body')
      gen_file_comment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the comment for this class
    def gen_file_comment(cls, bld); end

    # Returns the code for the content for this class
    def genFileContent(cls, bld); end
  end
end

XCTEPlugin.registerPlugin(XCTECss::ClassAngularReactiveView.new)
