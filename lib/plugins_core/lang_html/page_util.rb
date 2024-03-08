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
  class PageUtil
    include Singleton

    def get_page_footer(colCount, listVarName, asyncStr)
        tFoot = HtmlNode.new('tfoot')
        tFoot.add_attribute('*ngIf', '(' + listVarName + asyncStr + ')?.pageCount ?? 0 > 1')

        tFoot.add_child(make_paging_control(colCount, listVarName, asyncStr))
    end

    def make_paging_control(colCount, listVarName, asyncStr)
        tFootRow = HtmlNode.new('tr')
  
        tFootTd = HtmlNode.new('td')
        tFootTd.add_class('list-group-horizontal')
        tFootTd.add_attribute('colspan', colCount.to_s)
  
        firstPage = make_paging_button('&lt;&lt;', 'goToPage(0)')
        prevPage = make_paging_button('&lt;', 'goToPreviousPage()')
  
        pageList = HtmlNode.new('ul')
                           .add_class('pagination')
                           .add_class('list-group')
                           .add_class('list-group-horizontal')
  
        li = HtmlNode.new('li')
                     .add_child(firstPage)
        pageList.add_child(li)
  
        li = HtmlNode.new('li')
                     .add_child(prevPage)
        pageList.add_child(li)
  
        li = HtmlNode.new('li')
                     .add_attribute('*ngFor', 'let item of [].constructor((' + listVarName + asyncStr + ')?.pageCount ?? 0);let i = index')
                     .add_class('page-item')
                     .add_child(make_paging_button('{{i + 1}}', 'goToPage(i)'))
  
        # li = HtmlNode.new("li").add_attribute("*ngIf", "(" + listVarName + asyncStr + ")?.pageCount > 10)")
        pageList.add_child(li)
  
        nextPage = make_paging_button('&gt;', 'goToNextPage()')
        lastPage = make_paging_button('&gt;&gt;', 'goToPage(this.page.pageCount - 1)')
  
        li = HtmlNode.new('li')
                     .add_child(nextPage)
        pageList.add_child(li)
  
        li = HtmlNode.new('li')
                     .add_child(lastPage)
  
        pageList.add_child(li)
  
        tFootTd.add_child(pageList)
  
        tFootTd.add_child(HtmlNode.new('span').add_class('justify-content-end').add_text('Page '))
  
        tFootRow.add_child(tFootTd)
  
        return tFootRow
    end
    
    def make_paging_button(text, onClick)
        return HtmlNode.new('a')
                       .add_class('page-link')
                       .add_attribute('style', 'cursor: pointer')
                       .add_attribute('(click)', onClick)
                       .add_text(text)
    end
  end
end
