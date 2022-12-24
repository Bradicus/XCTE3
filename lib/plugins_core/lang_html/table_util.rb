##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile.rb"
require "code_name_styling.rb"
require "utils_base"
require "singleton"

module XCTEHtml
  class TableUtil
    include Singleton

    # Return formatted class name
    def render_table(cls, bld, listVar, iteratorName, async = "")
      bld.startBlock('<table class="table">')
      asyncStr = ""
      if async == "async"
        asyncStr = " | async"
      end

      # Generate table header
      bld.startBlock("<thead>")
      bld.startBlock("<tr>")

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var)
          varName = Utils.instance.getStyledVariableName(var)

          bld.add("<th>" + var.getDisplayName() + "</th>")
        end
      }))

      bld.endBlock("</tr>")
      bld.endBlock("</thead>")

      # Generate table body
      bld.startBlock("<tbody>")
      bld.startBlock('<tr *ngFor="let ' + iteratorName + " of " + listVar + asyncStr + '">')

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var)
          varName = Utils.instance.getStyledVariableName(var)

          bld.add("<td>{{" + iteratorName + "." + varName + "}}</td>")
        end
      }))

      bld.add('<td><a class="button" routerLink="/user/view/{{item.id}}">View</a></td>')
      bld.add('<td><a class="button" routerLink="/user/edit/{{item.id}}">Edit</a></td>')
      bld.endBlock("</tr>")
      bld.endBlock("</tbody>")

      bld.endBlock("</table>")
    end
  end
end