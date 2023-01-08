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
    def make_table(cls, listVarName, iteratorName, async = "")
      tableElem = HtmlNode.new("table")
        .add_class("table")

      asyncStr = ""
      if async == "async"
        asyncStr = " | async"
      end

      # Generate table header
      tHead = HtmlNode.new("thead")
      tHeadRow = HtmlNode.new("tr")

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var)
          tHeadRow.children.push(HtmlNode.new("th").add_text(var.getDisplayName()))
        end
      }))

      tHead.add_child(tHeadRow)
      tableElem.add_child(tHead)

      # Generate table body
      tBody = HtmlNode.new("tbody")
      tBodyRow = HtmlNode.new("tr").
        add_attribute("*ngFor", "let " + iteratorName + " of " + listVarName + asyncStr)

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var)
          tBodyRow.add_child(HtmlNode.new("td").
            add_text("{{" + iteratorName + "." + Utils.instance.getStyledVariableName(var) + "}}"))
        end
      }))

      tBody.add_child(tBodyRow)
      tableElem.add_child(tBody)

      # bld.add('<td><a class="button" routerLink="/' + Utils.instance.getStyledUrlName(cls.getUName()) + '/view/{{item.id}}">View</a></td>')
      # bld.add('<td><a class="button" routerLink="/' + Utils.instance.getStyledUrlName(cls.getUName()) + '/edit/{{item.id}}">Edit</a></td>')
      # bld.endBlock("</tr>")
      # bld.endBlock("</tbody>")

      # bld.endBlock("</table>")
    end

    def make_sel_option_table(listVar, optionsVar, iteratorName, async = "")
      tableElem = HtmlNode.new("table")
        .add_class("table")

      asyncStr = ""
      if async == "async"
        asyncStr = " | async"
      end

      # Generate table header
      tHead = HtmlNode.new("thead")
      tHeadRow = HtmlNode.new("tr")

      optClass = Classes.findVarClass(optionsVar)
      listVarName = Utils.instance.getStyledVariableName(optionsVar)

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(optClass).wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var)
          tHeadRow.children.push(HtmlNode.new("th").add_text(var.getDisplayName()))
        end
      }))

      tHead.add_child(tHeadRow)
      tableElem.add_child(tHead)

      # Generate table body
      tBody = HtmlNode.new("tbody")
      tBodyRow = HtmlNode.new("tr").
        add_attribute("*ngFor", "let " + iteratorName + " of " + listVarName + asyncStr)

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(optClass).wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var)
          tBodyRow.add_child(HtmlNode.new("td")) #.
          #add_text("{{" + iteratorName + "." + Utils.instance.getStyledVariableName(var) + "}}"))
        end
      }))

      tBody.add_child(tBodyRow)
      tableElem.add_child(tBody)

      return tableElem
    end
  end
end
