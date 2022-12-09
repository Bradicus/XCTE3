require "plugins_core/lang_ruby/utils.rb"
require "x_c_t_e_plugin.rb"

# This class contains functions that may be usefull in any type of class
module XCTERuby
  class ClassBase < XCTEPlugin
    def render_namespace_starts(cls, bld)
      for ns in cls.namespace.nsList
        bld.startBlock("module " + ns)
      end
    end

    def renderGlobalComment(bld)
      bld.add("##")

      for line in UserSettings.instance.codeLicense.split /[\r\n]+/
        if line.strip.length > 0
          bld.add("# " + line)
        end
      end
    end

    def render_namespace_ends(cls, bld)
      for ns in cls.namespace.nsList
        bld.endBlock
      end
    end
  end
end
