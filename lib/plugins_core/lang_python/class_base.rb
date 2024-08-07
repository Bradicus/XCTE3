require "plugins_core/lang_python/utils"
require "plugins_core/lang_python/source_renderer_python"
require "x_c_t_e_class_base"
require "active_component"

# This class contains functions that may be usefull in any type of class
module XCTEPython
  class ClassBase < XCTEClassBase
    def dutils
      return Utils.instance
    end

    def get_source_renderer
      return SourceRendererPython.new
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = get_source_renderer()
      bld.lfName = dutils().style_as_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = dutils().get_extension("body")

      process_dependencies(cls)

      render_file_comment(cls, bld)

      render_dependencies(cls, bld)
      render_namespace_start(cls, bld)

      render_body_content(cls, bld)

      render_namespace_end(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def render_namespace_start(cls, bld)
      for ns in cls.namespace.ns_list
        styledNs = dutils().style_as_namespace(ns)
        bld.start_block("module " + styledNs)
      end
    end

    def render_dependencies(cls, bld)
      for inc in cls.includes
        bld.add("require '" << dutils().style_as_path_name(inc.path) << "'")
      end

      bld.separate
    end

    def render_file_comment(cls, bld)
      dutils().render_block_comment(ActiveComponent.get().file_comment, bld)

      bld.separate

      # bld.add("##")
    end

    def render_class_comment(cls, bld)
      cfg = UserSettings.instance

      bld.add("##")
      bld.add("# @author " + cfg.codeAuthor) if !cfg.codeAuthor.nil?

      bld.add("# " + cfg.codeCompany) if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0

      bld.add("# " + cfg.codeLicense) if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0

      if !cls.description.nil?
        bld.add("# ")

        cls.description.each_line do |descLine|
          bld.add("# " << descLine.chomp) if descLine.strip.size > 0
        end
      end
    end

    def render_namespace_end(cls, bld)
      for ns in cls.namespace.ns_list
        bld.end_block
      end
    end
  end
end
