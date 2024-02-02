require 'plugins_core/lang_ruby/utils'
require 'plugins_core/lang_ruby/source_renderer_ruby'
require 'x_c_t_e_class_base'
require 'active_component'

# This class contains functions that may be usefull in any type of class
module XCTERuby
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end

    def get_source_renderer
      return SourceRendererRuby.new
    end
    
    def render_namespace_start(cls, bld)
      for ns in cls.namespace.nsList
        styledNs = get_default_utils().get_styled_namespace_name(ns)
        bld.start_block('module ' + styledNs)
      end
    end

    def render_dependencies(cls, bld)      
      for inc in cls.includes
        bld.add("require '" << get_default_utils().get_styled_path_name(inc.path) << "'")
      end

      bld.separate
    end

    def render_file_comment(cls, bld)
      get_default_utils().render_block_comment(ActiveComponent.get().file_comment, bld)

      bld.separate

      # bld.add("##")
    end
    
    def render_class_comment(cls, bld)
      cfg = UserSettings.instance
      
      bld.add('##')
      bld.add('# @author ' + cfg.codeAuthor) if !cfg.codeAuthor.nil?

      bld.add('# ' + cfg.codeCompany) if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0

      bld.add("# " + cfg.codeLicense) if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0

      if !cls.description.nil?
        bld.add('# ')
  
        cls.description.each_line do |descLine|
          bld.add('# ' << descLine.chomp) if descLine.strip.size > 0
        end
      end
    end

    def render_namespace_end(cls, bld)
      for ns in cls.namespace.nsList
        bld.end_block
      end
    end
  end
end
