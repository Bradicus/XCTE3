require "plugins_core/lang_csharp/utils.rb"
require "x_c_t_e_class_base.rb"

# This class contains functions that may be usefull in any type of class
module XCTECSharp
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end
  end
end
