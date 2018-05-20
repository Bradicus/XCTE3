##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin generates a create statement for a database based
# on this class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_razor/source_renderer_razor.rb'

module XCTERazor
  class RazorEditor < XCTEPlugin

    def initialize
      @name = "razor_edit"
      @language = "razor"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    def getClassName(dataModel, genClass)
      return Utils.instance.getStyledClassName(dataModel.name)
    end

    def genSourceFiles(dataModel, genClass, cfg)
      srcFiles = Array.new

      codeBuilder = SourceRendererRazor.new
      codeBuilder.lfName = Utils.instance.getStyledFileName(dataModel.name)
      codeBuilder.lfExtension = 'cshtml'
      genFileContent(dataModel, genClass, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    # Returns definition string for this class's constructor
    def genFileContent(dataModel, genClass, cfg, codeBuilder)
      sqlCDef = Array.new
      first = true

      codeBuilder.add("@Model " + genClass.namespaceList.join('.') + '.' +
                          XCTECSharp::Utils.instance.getStandardName(dataModel))
      codeBuilder.add
      codeBuilder.add("<form>")
      codeBuilder.indent

      processVarGroup(dataModel, genClass, cfg, codeBuilder, dataModel.groups)

      codeBuilder.unindent
      codeBuilder.add("</form>")

    end

    def processVarGroup(dataModel, genClass, cfg, codeBuilder, varGroup)
      
      for grp in varGroup
        for var in grp.vars
          if var.elementId == CodeElem::ELEM_VARIABLE
            if var.vtype == 'String'
              codeBuilder.add('<input type="text" name="' + 
                  XCTECSharp::Utils.instance.getStyledVariableName(var.name) + '" value="model.' +
                  XCTECSharp::Utils.instance.getStyledVariableName(var.name) + '" />')
            elsif var.vtype.start_with?('Int')
              codeBuilder.add('<input type="number" name="' + var.name + '" value="model.' + var.name + '" />')
            end
          end
        end

        processVarGroup(dataModel, genClass, cfg, codeBuilder, grp.groups)        
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTERazor::RazorEditor.new)

