require "plugins_core/lang_tsql/utils.rb"
require "x_c_t_e_class_base.rb"

# This class contains functions that may be usefull in any type of class
module XCTETSql
  class ClassBase < XCTEClassBase
    def dutils
      return Utils.instance
    end
  end
end
