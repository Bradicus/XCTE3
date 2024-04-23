##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders typescript code

require "source_renderer_brace_delim.rb"

require "plugins_core/lang_typescript/utils"
require "plugins_core/lang_typescript/component_config"

module XCTETypescript
  class SourceRendererTypescript < SourceRendererBraceDelim
    def initialize()
      super

      @hangingFunctionStart = true
    end

    def start_function(funName, fun)
      params = []

      for param in fun.parameters.vars
        params.push Utils.instance.get_param_dec(param)
      end

      if funName != "constructor"
        if (fun.returnValue.vtype != "void")
          returnStr = Utils.instance.get_type_name(fun.returnValue)
        else
          returnStr = "void"
        end
      else
        returnStr = nil
      end

      start_function_paramed(
        Utils.instance.style_as_function(funName),
        params,
        returnStr
      )
    end

    def comment_file(file_comm)
      add "/* "

      fc = file_comm.strip

      for line in fc.split("\n")
        add "* " + line.rstrip
      end
      add "*/"
    end

    def render_component_declaration(cfg)
      add("@Component({")
      indent
      add("selector: 'app-" + cfg.selector_name + "',")
      add("standalone: true,") if cfg.standalone
      add("imports: [ " + cfg.imports.join(", ") + " ],") if cfg.standalone
      add("templateUrl: './" + cfg.file_part + ".component.html',")
      add("styleUrls: ['./" + cfg.file_part + ".component.css']")
      unindent
      add("})")
    end
  end
end
