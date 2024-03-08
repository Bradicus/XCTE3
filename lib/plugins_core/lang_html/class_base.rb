##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require "plugins_core/lang_html/utils.rb"
require "x_c_t_e_class_base.rb"

# This class contains functions that may be usefull in any type of class
module XCTEHtml
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end
  end
end
