##

#
# Copyright XCTE Contributors
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

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererRazor.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName())
      bld.lfExtension = "cshtml"
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns definition string for this class's constructor
    def genFileContent(cls, bld)
      sqlCDef = Array.new
      first = true

      bld.add("@Model " + XCTECSharp::Utils.instance.getClassTypeName(cls))
      bld.add
      bld.add("<form>")
      bld.indent

      processVarGroup(cls, bld, cls.model.groups)

      bld.unindent
      bld.add("</form>")
    end

    def processVarGroup(cls, bld, varGroup)
      for grp in varGroup
        for var in grp.vars
          if var.elementId == CodeElem::ELEM_VARIABLE
            if var.vtype == "String"
              bld.add('<input type="text" name="' +
                      XCTECSharp::Utils.instance.getStyledVariableName(var.name) + '" value="model.' +
                      XCTECSharp::Utils.instance.getStyledVariableName(var.name) + '" />')
            elsif (var.vtype != nil && var.vtype.start_with?("Int")) || (var.utype != nil && var.utype.start_with?("int"))
              bld.add('<input type="number" name="' + var.name + '" value="model.' + var.name + '" />')
            end
          end
        end

        processVarGroup(cls, bld, grp.groups)
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTERazor::RazorEditor.new)
