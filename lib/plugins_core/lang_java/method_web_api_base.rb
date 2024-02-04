##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'
require 'code_name_styling'
require 'plugins_core/lang_java/utils'

module XCTEJava
  class MethodWebApiBase < XCTEPlugin
    def get_data_class(cls)
      if !cls.data_class.nil?
        data_class = ClassModelManager.findClass(cls.data_class.model_name, cls.data_class.plugin_name)
        if !data_class.nil?
          return data_class
        end
      end

      return cls
    end

    def process_dependencies(cls, _bld, _fun)
      data_class = get_data_class(cls)

      Utils.instance.requires_class_type(cls, data_class, 'class_db_entity')
      Utils.instance.requires_class_type(cls, data_class, 'tsql_data_store')
      Utils.instance.add_class_injection(cls, data_class, 'tsql_data_store')

      if !cls.data_class.nil?
        Utils.instance.requires_class_type(cls, data_class, 'class_mapper_dozer')
      end

      cls.addUse('java.util.*')
    end
  end
end
