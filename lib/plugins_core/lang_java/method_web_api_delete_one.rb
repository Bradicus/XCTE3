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
  class MethodWebApiDelete < MethodWebApiBase
    def initialize
      @name = 'method_web_api_delete_one'
      @language = 'java'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(cls, bld, fun)
      bld.add('/*')
      bld.add('* Web API delete single ' + cls.get_u_name)
      bld.add('*/')

      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, _fun)
      bld.add('public ' + Utils.instance.get_styled_class_name(cls.get_u_name) +
              ' ' + Utils.instance.get_styled_class_name('delete' + cls.get_u_name) + '(int id);')
    end

    def get_body(cls, bld, _fun)
      conDef = String.new
      data_class = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(data_class.get_u_name + ' data store', Utils.instance.langProfile.variableNameStyle)
      className = Utils.instance.get_styled_class_name(cls.get_u_name)
      mapperName = 'mapper'

      params = []
      idVar = cls.model.getIdentityVar

      params << '@RequestBody ' + className + ' item' if !idVar.nil?

      # bld.add "@CrossOrigin"
      bld.add '@DeleteMapping(path = "' + Utils.instance.getStyledUrlName(cls.get_u_name) + '",'
      bld.iadd 'consumes = MediaType.APPLICATION_JSON_VALUE, '
      bld.iadd 'produces = MediaType.APPLICATION_JSON_VALUE)'

      bld.start_function('public ResponseEntity<Boolean> Delete' + className +
                        '(' + params.join(', ') + ')')

      bld.add 'var dataItem = ' + dataStoreName + '.findById(item.id);'
      bld.separate

      bld.start_block 'if (dataItem.isPresent())'
      if !cls.data_class.nil?
        bld.add mapperName + '.map(item, dataItem.get());'
        bld.add(dataStoreName + '.delete(dataItem.get());')
        bld.add 'var returnItem = new ' + className + '();'
        bld.add mapperName + '.map(savedItem, returnItem);'

        bld.add 'return new ResponseEntity<Boolean>(true, HttpStatus.NO_CONTENT);'
      else
        bld.add(dataStoreName + '.delete(item);')
        bld.add 'return new ResponseEntity<Boolean>(true, HttpStatus.NO_CONTENT);'
      end

      bld.mid_block('else')
      bld.add 'return null;'
      bld.end_block

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodWebApiDelete.new)
