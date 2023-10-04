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
    def make_table(cls, listVarName, iteratorName, paging, async = "", embedded = false)
      tableElem = HtmlNode.new("table")
        .add_class("table")

      asyncStr = ""
      if async == "async"
        asyncStr = " | async"
      end

      # Generate table header
      tHead = HtmlNode.new("thead")
      tHeadRow = HtmlNode.new("tr")
      colCount = 0

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var) && !var.isList()
          tHeadRow.children.push(HtmlNode.new("th").add_text(var.getDisplayName()))
          colCount = colCount + 1
        end
      }))

      tHead.add_child(tHeadRow)
      tableElem.add_child(tHead)

      # Generate search fields
      names = load_search_names(cls)

      tHead = HtmlNode.new("thead")
      tHeadRow = HtmlNode.new("tr")

      if (names.length > 0)
        Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wVarCb(lambda { |var|
          if names.include?(var.name)
            searchInput = HtmlNode.new("input")
            searchInput.add_class("form-control")
            searchInput.add_attribute("id", Utils.instance.getStyledUrlName(cls.model.name + " " + var.name))
            th = HtmlNode.new("th")
            th.add_child(searchInput)
            tHeadRow.children.push(th)
          else
            tHeadRow.children.push(HtmlNode.new("th").add_text(""))
          end
        }))

        # Add one more row for actions
        tHeadRow.children.push(HtmlNode.new("th").add_text(""))

        tHead.add_child(tHeadRow)
        tableElem.add_child(tHead)
      end

      # Generate table body
      tBody = HtmlNode.new("tbody")
      tBodyRow = HtmlNode.new("tr").
        add_attribute("*ngFor", "let " + iteratorName + " of (" + listVarName + asyncStr + ")?.data")

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var) && !var.isList()
          tBodyRow.add_child(HtmlNode.new("td").
            add_text("{{" + iteratorName + "." + Utils.instance.getStyledVariableName(var) + "}}"))
        end
      }))

      actions = HtmlNode.new("th")

      if !embedded
        for act in cls.actions
          if act.linkModel != nil
            linkcls = ClassModelManager.findClass(act.linkModel, act.linkClass)
            clsPlug = XCTEPlugin::findClassPlugin("typescript", linkcls.plugName)
            route = clsPlug.get_full_route(linkcls, act.name)
            actions.add_child(make_action_button(act.name, "routerLink", route + "/" + '{{' + iteratorName + '.id}}'))
          elsif act.trigger != nil
            triggerFun = Utils.instance.getStyledFunctionName("on " + act.trigger) + "(" + iteratorName + ")"
            if act.trigger == 'delete'
              actions.add_child(make_action_button(act.name, "(click)", triggerFun))          
            else
              actions.add_child(make_action_button(act.name, "(click)", triggerFun))
            end
          end
        end
      end

      # Add actions
      tBodyRow.children.push(actions)

      tBody.add_child(tBodyRow)
      tableElem.add_child(tBody)

      if paging
        tFoot = HtmlNode.new("tfoot")
        tFoot.add_attribute("*ngIf", "(" + listVarName + asyncStr + ")?.pageCount ?? 0 > 1")

        tFoot.add_child(make_paging_control(colCount, listVarName, asyncStr))
        tableElem.add_child(tFoot)
      end

      return tableElem

      # bld.add('<td><a class="button" routerLink="/' + Utils.instance.getStyledUrlName(cls.getUName()) + '/view/{{item.id}}">View</a></td>')
      # bld.add('<td><a class="button" routerLink="/' + Utils.instance.getStyledUrlName(cls.getUName()) + '/edit/{{item.id}}">Edit</a></td>')
      # bld.endBlock("</tr>")
      # bld.endBlock("</tbody>")

      # bld.endBlock("</table>")
    end

    def load_search_names(cls)
      names = Array.new

      cls.xmlElement.elements.each("search_by") { |xmlNode|
        names.push(xmlNode.attributes["name"])
      }

      return names
    end

    def make_paging_control(colCount, listVarName, asyncStr)
      tFootRow = HtmlNode.new("tr")

      tFootTd = HtmlNode.new("td")
      tFootTd.add_class("list-group-horizontal")
      tFootTd.add_attribute("colspan", colCount.to_s)

      firstPage = make_paging_button("&lt;&lt;", "goToPage(0)")
      prevPage = make_paging_button("&lt;", "goToPreviousPage()")

      pageList = HtmlNode.new("ul")
        .add_class("pagination")
        .add_class("list-group")
        .add_class("list-group-horizontal")

      li = HtmlNode.new("li")
        .add_child(firstPage)
      pageList.add_child(li)

      li = HtmlNode.new("li")
        .add_child(prevPage)
      pageList.add_child(li)

      li = HtmlNode.new("li")
        .add_attribute("*ngFor", "let item of [].constructor((" + listVarName + asyncStr + ")?.pageCount ?? 0);let i = index")
        .add_class("page-item")
        .add_child(make_paging_button("{{i + 1}}", "goToPage(i)"))

      #li = HtmlNode.new("li").add_attribute("*ngIf", "(" + listVarName + asyncStr + ")?.pageCount > 10)")
      pageList.add_child(li)

      nextPage = make_paging_button("&gt;", "goToPage(this.page.pageCount - 1)")
      lastPage = make_paging_button("&gt;&gt;", "goToNextPage()")

      li = HtmlNode.new("li")
        .add_child(nextPage)
      pageList.add_child(li)

      li = HtmlNode.new("li")
        .add_child(lastPage)

      pageList.add_child(li)

      tFootTd.add_child(pageList)

      tFootTd.add_child(HtmlNode.new("span").add_class("justify-content-end").add_text("Page "))

      tFootRow.add_child(tFootTd)

      return tFootRow
    end

    def make_paging_button(text, onClick)
      return HtmlNode.new("a")
               .add_class("page-link")
               .add_attribute("(click)", onClick)
               .add_text(text)
    end

    def make_action_button(text, attrib, attribValue)      
      return HtmlNode.new("button")
        .add_class('btn btn-primary')
        .add_attribute(attrib, attribValue)
        .add_text(text.capitalize)
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

      optClass = ClassModelManager.findVarClass(optionsVar)
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
        add_attribute("*ngFor", "let " + iteratorName + " of (" + listVarName + asyncStr + ")?.data")

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(optClass).wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var)
          td = HtmlNode.new("td")
          ##            .add_text("{{" + iteratorName + "." + Utils.instance.getStyledVariableName(var) + "}}")
          td.add_child(HtmlNode.new("a")
            .add_class("page-link")
            .add_text("{{i}}}"))
          tBodyRow.add_child(td)
        end
      }))

      tBody.add_child(tBodyRow)
      tableElem.add_child(tBody)

      return tableElem
    end
  end
end
