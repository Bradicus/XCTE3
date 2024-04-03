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

module XCTEHtml
  class SearchUtil
    include Singleton

    def make_search_row(cls)
      searchRow = HtmlNode.new("tr")

      if cls.model.data_filter.has_search_filter?
        Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wVarCb(lambda { |var|
          if Utils.instance.is_primitive(var) && !var.isList
            found = false
            for col in cls.model.data_filter.search_filter.columns
              if col == var.name
                searchCol = HtmlNode.new("th")
                searchInput = gen_search_input(col + " search", "on search " + col)

                searchCol.add_child(searchInput)
                found = true
              end
            end

            if !found
              searchCol = HtmlNode.new("th")
            end

            searchRow.add_child(searchCol)
          end
        }))
      end

      return searchRow
    end

    def make_search_area(cls)
      searchRow = HtmlNode.new("div").add_class("row")

      if cls.model.data_filter.has_search_filter?
        searchCol = HtmlNode.new("div").add_class("col-3")
        searchInput = gen_search_input(cls.model.name + " search", "on search")

        searchCol.add_child(searchInput)
        searchRow.add_child(searchCol)
      end

      return searchRow
    end

    def gen_search_input(id_name, search_fun_name)
      searchInput = HtmlNode.new("input")
        .add_class("form-control")
        .add_attribute("type", "search")
        .add_attribute("placeholder", "Search")
        .add_attribute("id", Utils.instance.get_styled_url_name(id_name))
        .add_attribute("(keyup)", Utils.instance.style_as_function(search_fun_name) + "($event)")
    end
  end
end
