##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin generates a create statement for a database based
# on this class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_razor/source_renderer_razor'
require 'plugins_core/lang_razor/class_base'

module XCTERazor
  class RazorEditor < ClassBase
    def initialize
      @name = 'razor_edit'
      @language = 'razor'
      @category = XCTEPlugin::CAT_METHOD
      @author = 'Brad Ottoson'
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererRazor.new
      bld.lfName = Utils.instance.get_styled_file_name(cls.getUName)
      bld.lfExtension = 'cshtml'
      gen_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns definition string for this class's constructor
    def gen_body_content(cls, bld)
      sqlCDef = []
      first = true

      bld.add('@Model ' + XCTECSharp::Utils.instance.getClassTypeName(cls))
      bld.add
      bld.add('<form>')
      bld.indent

      processVarGroup(cls, bld, cls.model.groups)

      bld.unindent
      bld.add('</form>')
    end

    def processVarGroup(cls, bld, varGroup)
      for grp in varGroup
        for var in grp.vars
          if var.elementId == CodeElem::ELEM_VARIABLE
            if var.vtype == 'String'
              bld.add('<input type="text" name="' +
                      XCTECSharp::Utils.instance.get_styled_variable_name(var.name) + '" value="model.' +
                      XCTECSharp::Utils.instance.get_styled_variable_name(var.name) + '" />')
            elsif (!var.vtype.nil? && var.vtype.start_with?('Int')) || (!var.utype.nil? && var.utype.start_with?('int'))
              bld.add('<input type="number" name="' + var.name + '" value="model.' + var.name + '" />')
            end
          end
        end

        processVarGroup(cls, bld, grp.groups)
      end
    end
  end
end

XCTEPlugin.registerPlugin(XCTERazor::RazorEditor.new)
