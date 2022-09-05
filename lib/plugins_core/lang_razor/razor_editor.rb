##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin generates a create statement for a database based
# on this class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_razor/source_renderer_razor.rb"

module XCTERazor
  class RazorEditor < XCTEPlugin
    def initialize
      @name = "razor_edit"
      @language = "razor"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(cls.getUName())
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      codeBuilder = SourceRendererRazor.new
      codeBuilder.lfName = Utils.instance.getStyledFileName(cls.getUName())
      codeBuilder.lfExtension = "cshtml"
      genFileContent(cls, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    # Returns definition string for this class's constructor
    def genFileContent(cls, cfg, codeBuilder)
      sqlCDef = Array.new
      first = true

      codeBuilder.add("@Model " + XCTECSharp::Utils.instance.getClassTypeName(cls))
      codeBuilder.add
      codeBuilder.add("<form>")
      codeBuilder.indent

      processVarGroup(cls, cfg, codeBuilder, cls.model.groups)

      codeBuilder.unindent
      codeBuilder.add("</form>")
    end

    def processVarGroup(cls, cfg, codeBuilder, varGroup)
      for grp in varGroup
        for var in grp.vars
          if var.elementId == CodeElem::ELEM_VARIABLE
            if var.vtype == "String"
              codeBuilder.add('<input type="text" name="' +
                              XCTECSharp::Utils.instance.getStyledVariableName(var.name) + '" value="model.' +
                              XCTECSharp::Utils.instance.getStyledVariableName(var.name) + '" />')
            elsif (var.vtype != nil && var.vtype.start_with?("Int")) || (var.utype != nil && var.utype.start_with?("int"))
              codeBuilder.add('<input type="number" name="' + var.name + '" value="model.' + var.name + '" />')
            end
          end
        end

        processVarGroup(cls, cfg, codeBuilder, grp.groups)
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTERazor::RazorEditor.new)
