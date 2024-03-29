##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

module XCTEHtml
  class HtmlNode
    attr_accessor :name, :classAttrib, :attribs, :children, :text, :selfClose

    @selfClose = false

    def initialize(name)
      @name = name

      @classAttrib = Array.new
      @attribs = Hash.new
      @text = ""
      @children = Array.new
      @selfClose = false

      if (name == "area" ||
          name == "base" ||
          name == "br" ||
          name == "col" ||
          name == "meta" ||
          name == "embed" ||
          name == "hr" ||
          name == "img" ||
          name == "input" ||
          name == "source" ||
          name == "link" ||
          name == "wbr" ||
          name == "param" ||
          name == "track" ||
          name == "command" ||
          name == "keygen" ||
          name == "menuitem")
        @selfClose = true
      end
    end

    def add_class(cl1Name, cl2Name = nil)
      @classAttrib.push(cl1Name)

      if (cl2Name != nil)
        @classAttrib.push(cl2Name)
      end
      return self
    end

    def add_attribute(attName, attValue)
      @attribs[attName] = attValue
      return self
    end

    def add_text(txt)
      @text += txt

      return self
    end

    def add_child(node)
      if !node.kind_of?(HtmlNode)
        throw "Invalid node"
      end
      @children.push(node)

      return self
    end
  end
end
