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
  class MethodWebApiWrite < MethodWebApiBase
    def initialize
      @name = 'method_web_api_write_one'
      @language = 'java'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add('/*')
      bld.add('* Web API create single ' + cls.getUName)
      bld.add('*/')

      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, _fun)
      bld.add('public ' + Utils.instance.get_styled_class_name(cls.getUName) +
              ' Post' + Utils.instance.get_styled_class_name(cls.getUName) + '(int id);')
    end

    def process_dependencies(cls, bld, fun)
      if !fun.role.nil?
        cls.addUse('org.springframework.security.access.prepost.PreAuthorize')
      end
    end

    def get_body(cls, bld, fun)
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
      if !fun.role.nil?
        bld.add '@PreAuthorize("hasAuthority(\'' + fun.role + '\')")'
      end

      bld.add '@PostMapping(path = "' + Utils.instance.getStyledUrlName(cls.getUName) + '",'
      bld.iadd 'consumes = MediaType.APPLICATION_JSON_VALUE, '
      bld.iadd 'produces = MediaType.APPLICATION_JSON_VALUE)'

      bld.startFunction('public ResponseEntity<' + className +
                        '> Post' + className +
                        '(' + params.join(', ') + ')')

      if !cls.dataClass.nil?
        bld.add 'var dataItem = new ' + Utils.instance.get_styled_class_name(dataClass.getUName) + '();'
        bld.add mapperName + '.map(item, dataItem);'
        bld.add(Utils.instance.get_styled_class_name(dataClass.getUName) + ' savedItem = ' + dataStoreName + '.saveAndFlush(dataItem);')
        bld.separate
        bld.add 'var returnItem = new ' + className + '();'
        bld.add mapperName + '.map(savedItem, returnItem);'

        bld.add 'return new ResponseEntity<' + className + '>(returnItem, HttpStatus.CREATED);'
      else
        bld.add(Utils.instance.get_styled_class_name(dataClass.getUName) + ' savedItem = ' + dataStoreName + '.saveAndFlush(item);')
        bld.add 'return new ResponseEntity<' + className + '>(savedItem, HttpStatus.CREATED);'
      end

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodWebApiWrite.new)
