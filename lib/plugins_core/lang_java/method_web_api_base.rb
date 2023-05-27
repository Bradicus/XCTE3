##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin"
require "code_name_styling"
require "plugins_core/lang_java/utils"

module XCTEJava
  class MethodWebApiBase < XCTEPlugin
    def get_data_class(cls)
      if cls.dataClass != nil
        dataClass = ClassModelManager.findClass(cls.dataClass.className, cls.dataClass.pluginName)
        if dataClass != nil
          return dataClass
        end
      end

      return cls
    end

    def process_dependencies(cls, bld, fun)
      dataClass = get_data_class(cls)

      Utils.instance.requires_class_type(cls, dataClass, "class_jpa_entity")
      Utils.instance.requires_class_type(cls, dataClass, "tsql_data_store")
      Utils.instance.add_class_injection(cls, dataClass, "tsql_data_store")

      if cls.dataClass != nil
        Utils.instance.requires_class_type(cls, dataClass, "class_mapper_dozer")
        Utils.instance.add_class_injection(cls, dataClass, "class_mapper_dozer")
      end

      cls.addUse("java.util.*")
    end
  end
end
