require "plugins_core/lang_ruby/utils.rb"
require "x_c_t_e_class_base.rb"

# This class contains functions that may be usefull in any type of class
module XCTERuby
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end

    def render_namespace_starts(cls, bld)
      for ns in cls.namespace.nsList
        styledNs = get_default_utils().getStyledNamespaceName(ns)
        bld.startBlock("module " + styledNs)
      end
    end

    def renderGlobalComment(pComponent, bld)
      get_default_utils().render_block_comment(pComponent.headerComment, bld)

      bld.separate

      #bld.add("##")
    end

    def render_namespace_ends(cls, bld)
      for ns in cls.namespace.nsList
        bld.endBlock
      end
    end
  end
end
