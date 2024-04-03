##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile"
require "code_name_styling"
require "utils_base"
require "singleton"
require "plugins_core/lang_html/page_util"
require "plugins_core/lang_html/search_util"

module XCTEHtml
  class TableUtil
    include Singleton

    # Return formatted class name
    def make_table(table_cfg)
      cls = table_cfg.item_class

      integrated_search = !cls.model.data_filter.has_shared_filter? && table_cfg.is_paged?

      tableDiv = HtmlNode.new("div")

      if !integrated_search && !table_cfg.is_embedded
        tableDiv.add_child(SearchUtil.instance.make_search_area(cls))
      end

      tableElem = HtmlNode.new("table")
                          .add_class("table")

      tableDiv.add_child(tableElem)

      asyncStr = ""
      if table_cfg.is_observable
        asyncStr = " | async"
      end

      # Generate table header
      tHead = HtmlNode.new("thead")

      # Generate search header, if needed
      if integrated_search && !table_cfg.is_embedded
        tHead.add_child(SearchUtil.instance.make_search_row(cls))
      end

      tHeadRow = HtmlNode.new("tr")
      colCount = 0

      if table_cfg.is_paged?
        add_sortable_header(cls, tHeadRow, colCount)
      end

      tHead.add_child(tHeadRow)
      tableElem.add_child(tHead)

      # Generate table body
      tBody = HtmlNode.new("tbody")

      tBody.add_child(gen_row(table_cfg))
      tableElem.add_child(tBody)

      if table_cfg.is_paged?
        tableElem.add_child(PageUtil.instance.get_page_footer(colCount, table_cfg.container_var_name, asyncStr))
      end

      return tableDiv

      # bld.add('<td><a class="button" routerLink="/' + Utils.instance.get_styled_url_name(cls.get_u_name()) + '/view/{{item.id}}">View</a></td>')
      # bld.add('<td><a class="button" routerLink="/' + Utils.instance.get_styled_url_name(cls.get_u_name()) + '/edit/{{item.id}}">Edit</a></td>')
      # bld.end_block("</tr>")
      # bld.end_block("</tbody>")

      # bld.end_block("</table>")
    end

    def add_sortable_header(cls, tHeadRow, colCount)
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wVarCb(lambda { |var|
        if Utils.instance.is_primitive(var) && !var.isList
          tHeadRow.children.push(HtmlNode.new("th")
            .add_text(var.getdisplay_name)
            .add_child(HtmlNode.new("i").add_class("bi bi-arrow-bar-down"))
            .add_attribute("scope", "col")
            .add_attribute("style", "cursor: pointer")
            .add_attribute("(click)", "sortBy('" + Utils.instance.get_styled_variable_name(var) + "')"))
          colCount += 1
        end
      }))
    end

    def gen_row(table_cfg)
      rowLoop = HtmlNode.new("loop")

      tBodyRow = HtmlNode.new("tr")
      rowLoop.add_child(tBodyRow)

      asyncStr = ""
      if table_cfg.is_observable
        asyncStr = " | async"
      end

      if table_cfg.is_paged?
        rowLoop.add_text("@for (" + table_cfg.iterator_var_name + " of (" + table_cfg.container_var_name + asyncStr + ")?.data; track " + table_cfg.iterator_var_name + ".id) {")
      else
        rowLoop.add_text("@for (" + table_cfg.iterator_var_name + " of (" + table_cfg.container_var_name + asyncStr + ") track " + table_cfg.iterator_var_name + ".id) {")
      end

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(table_cfg.item_class).wVarCb(lambda { |var|
        if Utils.instance.is_primitive(var) && !var.isList
          if var.getUType.downcase.start_with? "date"
            tBodyRow.add_child(HtmlNode.new("td")
              .add_text("{{" + table_cfg.iterator_var_name + "." + Utils.instance.get_styled_variable_name(var) + " | date:'medium'}}"))
          else
            tBodyRow.add_child(HtmlNode.new("td")
              .add_text("{{" + table_cfg.iterator_var_name + "." + Utils.instance.get_styled_variable_name(var) + "}}"))
          end
        end
      }))

      actions = HtmlNode.new("th")

      if table_cfg.is_paged? && !table_cfg.is_embedded
        for act in table_cfg.item_class.actions
          if !act.link.nil?
            actions.add_child(make_action_button(act.name, "routerLink",
                                                 act.link + "/" + "{{" + table_cfg.iterator_var_name + ".id}}"))
          elsif !act.trigger.nil?
            triggerFun = Utils.instance.style_as_function("on " + act.trigger) + "(" + table_cfg.iterator_var_name + ")"
            if act.trigger == "delete"
              actions.add_child(make_action_button(act.name, "(click)", triggerFun))
            else
              actions.add_child(make_action_button(act.name, "(click)", triggerFun))
            end
          end
        end
      end

      # Add actions
      tBodyRow.children.push(actions)

      return rowLoop
    end

    def make_relation_table(table_cfg)
      tableDiv = HtmlNode.new("div")

      tableElem = HtmlNode.new("table")
                          .add_class("table")

      tableDiv.add_child(tableElem)

      # Generate table header
      tHead = HtmlNode.new("thead")

      tHeadRow = HtmlNode.new("tr")
      colCount = 0

      tHead.add_child(tHeadRow)
      tableElem.add_child(tHead)

      # Generate table body
      tBody = HtmlNode.new("tbody")

      tBody.add_child(gen_row(table_cfg))
      tableElem.add_child(tBody)

      return tableDiv
    end

    def make_action_button(text, attrib, attribValue)
      return HtmlNode.new("button")
                     .add_class("btn btn-primary btn-sm")
                     .add_attribute(attrib, attribValue)
                     .add_text(text.capitalize)
    end

    def make_sel_option_table(_listVar, optionsVar, iteratorName, async = "")
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
      listVarName = Utils.instance.get_styled_variable_name(optionsVar)

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(optClass).wVarCb(lambda { |var|
        if Utils.instance.is_primitive(var)
          tHeadRow.children.push(HtmlNode.new("th").add_text(var.getdisplay_name))
        end
      }))

      tHead.add_child(tHeadRow)
      tableElem.add_child(tHead)

      # Generate table body
      tBody = HtmlNode.new("tbody")
      tBodyRow = HtmlNode.new("tr")
                         .add_attribute("*ngFor", "let " + iteratorName + " of (" + listVarName + asyncStr + ")?.data")

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(optClass).wVarCb(lambda { |var|
        if Utils.instance.is_primitive(var)
          td = HtmlNode.new("td")
          ##            .add_text("{{" + iteratorName + "." + Utils.instance.get_styled_variable_name(var) + "}}")
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
