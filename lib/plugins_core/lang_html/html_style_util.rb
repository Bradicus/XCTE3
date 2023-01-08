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
  class HtmlStyleUtil
    include Singleton

    def stylePrimaryButton(genCfg, htmlNode)
      if (genCfg.usesExternalDependency("bootstrap"))
        htmlNode.add_class('btn', 'btn-primary')
      end
    end
  end
end
