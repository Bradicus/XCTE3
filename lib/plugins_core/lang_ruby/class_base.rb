require 'plugins_core/lang_ruby/utils'
require 'x_c_t_e_class_base'

# This class contains functions that may be usefull in any type of class
module XCTERuby
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end

    def render_namespace_starts(cls, bld)
      for ns in cls.namespace.nsList
        styledNs = get_default_utils().get_styled_namespace_name(ns)
        bld.start_block('module ' + styledNs)
      end
    end

    def renderGlobalComment(pComponent, bld)
      get_default_utils().render_block_comment(pComponent.file_comment, bld)

      bld.separate

      # bld.add("##")
    end

    def render_namespace_ends(cls, bld)
      for ns in cls.namespace.nsList
        bld.end_block
      end
    end
  end
end
