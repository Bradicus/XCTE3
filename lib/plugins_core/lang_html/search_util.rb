##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'
require 'code_name_styling'
require 'utils_base'
require 'singleton'

module XCTEHtml
  class SearchUtil
    include Singleton

    def make_search_row(cls)
        searchRow = HtmlNode.new('tr').add_class('row') 

        if cls.model.data_filter.has_search_filter
            if cls.model.data_filter.search_filter.type == 'shared'  
                searchCol = HtmlNode.new('th')

                searchInput = HtmlNode.new('input')
                                        .add_class('form-control')
                                        .add_attribute('type', 'search')
                                        .add_attribute('placeholder', 'Search')
                                        .add_attribute('id', Utils.instance.getStyledUrlName(cls.model.name + ' search'))
                                        .add_attribute('(keyup)', 'onSearch($event)')

                searchCol.add_child(searchInput)
                searchRow.add_child(searchCol)
            else
                for col in cls.model.data_filter.search_filter.columns
                searchCol = HtmlNode.new('th')

                searchInput = HtmlNode.new('input')
                                            .add_class('form-control')
                                            .add_attribute('type', 'search')
                                            .add_attribute('placeholder', 'Search')
                                            .add_attribute('id', Utils.instance.getStyledUrlName(col + ' search'))
                                            .add_attribute('(keyup)', 'onSearch($event)')
        
                searchCol.add_child(searchInput)
                searchRow.add_child(searchCol)
                end
            end
        end

        return searchRow
    end
  end
end