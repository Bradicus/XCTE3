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
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("html")
    end

    # Return formatted class name
    def getClassName(var)
      if (var.vtype != nil)
        return @langProfile.getTypeName(var.vtype)
      else
        return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end
    end

    def getInputType(var)
      if (var.vtype != nil)
        lowType = var.vtype.downcase
        if (lowType.start_with?("int") || lowType.start_with?("float"))
          return "number"
        elsif lowType == "datetime"
          return "datetime-local"
        elsif lowType == "date"
          return "date"
        end
      end

      return "text"
    end

    def getStyledUrlName(name)
      return CodeNameStyling.getStyled(name, "DASH_LOWER")
    end
  end
end
