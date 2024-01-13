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
  class MethodWebApiUpdate < MethodWebApiBase
    def initialize
      @name = 'method_web_api_update_one'
      @language = 'java'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add('/*')
      bld.add('* Web API update single ' + cls.getUName)
      bld.add('*/')

      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, _fun)
      bld.add('public ' + Utils.instance.get_styled_class_name(cls.getUName) +
              ' ' + Utils.instance.get_styled_class_name('put' + cls.getUName) + '(int id);')
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse('org.springframework.web.bind.annotation.PutMapping')
      cls.addUse('org.springframework.web.bind.annotation.RequestBody')
      cls.addUse('org.springframework.http.MediaType')
      cls.addUse('org.springframework.http.ResponseEntity')
    end

    def get_body(cls, bld, _fun)
      conDef = String.new
      dataClass = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(dataClass.getUName + ' data store', Utils.instance.langProfile.variableNameStyle)
      className = Utils.instance.get_styled_class_name(cls.getUName)
      mapperName = 'mapper'

      params = []
      idVar = cls.model.getIdentityVar

      params << '@RequestBody ' + className + ' item' if !idVar.nil?

      # bld.add "@CrossOrigin"
      bld.add '@PutMapping(path = "' + Utils.instance.getStyledUrlName(cls.getUName) + '",'
      bld.iadd 'consumes = MediaType.APPLICATION_JSON_VALUE, '
      bld.iadd 'produces = MediaType.APPLICATION_JSON_VALUE)'

      bld.start_function('public ResponseEntity<' + className +
                        '> Put' + className +
                        '(' + params.join(', ') + ')')

      bld.add 'var dataItem = ' + dataStoreName + '.findById(item.id);'
      bld.separate

      bld.start_block 'if (dataItem.isPresent())'
      if !cls.dataClass.nil?
        bld.add mapperName + '.map(item, dataItem.get());'
        bld.add(Utils.instance.get_styled_class_name(dataClass.getUName) + ' savedItem = ' + dataStoreName + '.saveAndFlush(dataItem.get());')
        bld.add 'var returnItem = new ' + className + '();'
        bld.add mapperName + '.map(savedItem, returnItem);'

        bld.add 'return new ResponseEntity<' + className + '>(returnItem, HttpStatus.CREATED);'
      else
        bld.add(Utils.instance.get_styled_class_name(dataClass.getUName) + ' savedItem = ' + dataStoreName + '.saveAndFlush(item);')
        bld.add 'return new ResponseEntity<' + className + '>(savedItem, HttpStatus.CREATED);'
      end

      bld.mid_block('else')
      bld.add 'return null;'
      bld.end_block

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodWebApiUpdate.new)
