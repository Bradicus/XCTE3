require 'plugins_core/lang_html/class_base'

module XCTEHtml
  ##
  # Class:: ClassAngularListing
  #
  class ClassAngularListing < ClassBase
    def initialize
      super

      @name = 'class_angular_listing'
      @language = 'html'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls) + '.component')
      bld.lfExtension = Utils.instance.get_extension('body')
      # render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      if cls.model.findClassModel('class_angular_reactive_edit')
        plug = XCTEPlugin.findClassPlugin('typescript', 'class_angular_reactive_edit')

        bld.add('<button type="button" class="btn btn-primary btn-sm" routerLink="/' +
                plug.get_full_route(cls, 'edit') + '/0">New ' + cls.get_u_name + '</button>')
      end

      tbl = TableUtil.instance.make_table(cls, 'page', 'item', 'async', true)

      bld.render_html(tbl)
    end
  end
end

XCTEPlugin.registerPlugin(XCTEHtml::ClassAngularListing.new)
