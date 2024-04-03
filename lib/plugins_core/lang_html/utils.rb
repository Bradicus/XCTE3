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
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("html")
    end

    def make_primary_button(genCfg, bText)
      newButton = HtmlNode.new("button").
        add_attribute("type", "button").
        add_text(bText)

      HtmlStyleUtil.instance.stylePrimaryButton(genCfg, newButton)

      return newButton
    end

    def make_node(_genCfg, nodeName)
      newNode = HtmlNode.new(nodeName)

      return newNode
    end

    # Return formatted class name
    def get_class_name(var)
      if !var.vtype.nil?
        return @langProfile.get_type_name(var.vtype)
      else
        return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end
    end

    def getInputType(var)
      if !var.vtype.nil?
        lowType = var.vtype.downcase
        if lowType.start_with?("int") || lowType.start_with?("float")
          return "number"
        elsif lowType.include?("email")
          return "email"
        elsif lowType.include?("phone")
          return "tel"
        elsif lowType == "datetime"
          return "datetime-local"
        elsif lowType == "date"
          return "date"
        elsif lowType == "boolean"
          return "checkbox"
        end
      end

      return "text"
    end

    def get_styled_url_name(name)
      return CodeNameStyling.getStyled(name, "DASH_LOWER")
    end
  end
end
