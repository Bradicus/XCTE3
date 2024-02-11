require 'plugins_core/lang_css/utils'
require 'plugins_core/lang_css/class_base'
require 'x_c_t_e_plugin'

##
# Class:: ClassAngularListing
#
module XCTECss
  class ClassAngularReactiveView < ClassBase
    def initialize
      @name = 'class_angular_reactive_view'
      @language = 'css'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    # Returns the code for the comment for this class
    def render_file_comment(cls, bld); end

    # Returns the code for the content for this class
    def render_body_content(cls, bld); end
  end
end

XCTEPlugin.registerPlugin(XCTECss::ClassAngularReactiveView.new)
