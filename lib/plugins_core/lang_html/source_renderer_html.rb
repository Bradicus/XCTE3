##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class renders php code

require "source_renderer.rb"

class SourceRendererHtml < SourceRenderer
  def initialize()
    super

    @blockDelimOpen = ""
    @blockDelimClose = ""
  end

  def render_html(htmlNodes)
    if !htmlNodes.kind_of?(Array)
      render_html_node(htmlNodes)
    else
      for htmlNode in htmlNodes
        render_html_node(htmlNode)
      end
    end
  end

  def render_html_node(htmlNode)
    add('<' + htmlNode.name)
    allAttribs = Hash.new

    if htmlNode.classAttrib.length > 0
      allAttribs['class'] = htmlNode.classAttrib.join(' ')
    end

    allAttribs.merge!(htmlNode.attribs)

    if allAttribs.length > 0
      allAttribs.each do |key, value|
        sameLine(' ' + key + '="' + value + '"')
      end
    end

    if htmlNode.selfClose
      sameLine(' />')
    else
      sameLine('>')
      indent

      if htmlNode.text.length > 0
        sameLine(htmlNode.text)
      end

      for child in htmlNode.children
        render_html_node(child)
      end

      unindent

      if htmlNode.children.length > 0
        add('</' + htmlNode.name + '>')
      else
        sameLine('</' + htmlNode.name + '>')
      end
    end
  end
end
