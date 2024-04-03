##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "plugins_core/lang_java/method_web_api_base"
require "code_name_styling"
require "plugins_core/lang_java/utils"

module XCTEJava
  class MethodWebApiWrite < MethodWebApiBase
    def initialize
      @name = "method_web_api_write_one"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(cls, bld, fun)
      bld.add("/*")
      bld.add("* Web API create single " + cls.get_u_name)
      bld.add("*/")

      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, _fun)
      bld.add("public " + Utils.instance.style_as_class(cls.get_u_name) +
              " Post" + Utils.instance.style_as_class(cls.get_u_name) + "(int id);")
    end

    def process_dependencies(cls, _bld, fun)
      if !fun.role.nil?
        cls.addUse("org.springframework.security.access.prepost.PreAuthorize")
      end
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      data_class = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(data_class.get_u_name + " data store", Utils.instance.langProfile.variableNameStyle)
      className = Utils.instance.style_as_class(cls.get_u_name)
      mapperName = "mapper"

      params = []
      idVar = cls.model.getIdentityVar

      params << "@RequestBody " + className + " item" if !idVar.nil?

      # bld.add "@CrossOrigin"
      if !fun.role.nil?
        bld.add '@PreAuthorize("hasAuthority(\'' + fun.role + '\')")'
      end

      bld.add '@PostMapping(path = "' + Utils.instance.get_styled_url_name(cls.get_u_name) + '",'
      bld.iadd "consumes = MediaType.APPLICATION_JSON_VALUE, "
      bld.iadd "produces = MediaType.APPLICATION_JSON_VALUE)"

      bld.start_function("public ResponseEntity<" + className +
                         "> Post" + className +
                         "(" + params.join(", ") + ")")

      if !cls.data_class.nil?
        bld.add "var dataItem = new " + Utils.instance.style_as_class(data_class.get_u_name) + "();"
        bld.add mapperName + ".map(item, dataItem);"
        bld.add(Utils.instance.style_as_class(data_class.get_u_name) + " savedItem = " + dataStoreName + ".saveAndFlush(dataItem);")
        bld.separate
        bld.add "var returnItem = new " + className + "();"
        bld.add mapperName + ".map(savedItem, returnItem);"

        bld.add "return new ResponseEntity<" + className + ">(returnItem, HttpStatus.CREATED);"
      else
        bld.add(Utils.instance.style_as_class(data_class.get_u_name) + " savedItem = " + dataStoreName + ".saveAndFlush(item);")
        bld.add "return new ResponseEntity<" + className + ">(savedItem, HttpStatus.CREATED);"
      end

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodWebApiWrite.new)
