##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'plugins_core/lang_java/method_web_api_base'
require 'code_name_styling'
require 'plugins_core/lang_java/utils'

module XCTEJava
  class MethodWebApiRead < MethodWebApiBase
    def initialize
      super

      @name = 'method_web_api_read_one'
      @language = 'java'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add('/*')
      bld.add('* Web API get single ' + cls.getUName)
      bld.add('*/')

      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, _fun)
      bld.add('public ' + Utils.instance.get_styled_class_name(cls.getUName) +
              ' Get' + Utils.instance.get_styled_class_name(cls.getUName) + '(int id);')
    end

    def get_body(cls, bld, _fun)
      conDef = String.new
      dataClass = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(dataClass.getUName + ' data store', Utils.instance.langProfile.variableNameStyle)
      mapperName = 'mapper'

      params = []
      idVar = cls.model.getIdentityVar

      if !idVar.nil?
        params << '@PathVariable("' + Utils.instance.get_styled_variable_name(idVar) + '") ' + Utils.instance.getParamDec(idVar)
      end

      bld.add('@GetMapping("' + Utils.instance.getStyledUrlName(cls.getUName) + '/{id}")')

      bld.startFunction('public ' + Utils.instance.get_styled_class_name(cls.getUName) +
                        ' Get' + Utils.instance.get_styled_class_name(cls.getUName) +
                        '(' + params.join(', ') + ')')

      bld.add('var item = ' + dataStoreName + '.findById(id);')
      bld.separate

      if !cls.dataClass.nil?
        bld.startBlock 'if (item.isPresent())'
        bld.add 'var mappedItem = new ' + Utils.instance.get_styled_class_name(cls.getUName) + '();'
        bld.add(mapperName + '.map(item.get(), mappedItem);')
        bld.add('return mappedItem;')
        bld.endBlock

        bld.add 'return null;'
      else
        bld.add('return item.get();')
      end

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodWebApiRead.new)
