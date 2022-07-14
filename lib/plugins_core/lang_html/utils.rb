##

#
# Copyright (C) 2008 Brad Ottoson
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
        lowType = var.vtype.to_lower()
        if (lowType.starts_with("int") || lowType.starts_with("float"))
          return "number"
        end
      end

      return "text"
    end
  end
end
