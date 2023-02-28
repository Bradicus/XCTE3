##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "code_name_styling.rb"
require "plugins_core/lang_java/utils.rb"

module XCTEJava
  class MethodWebApiUpdate < XCTEPlugin
    def initialize
      @name = "method_web_api_update_one"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add("/*")
      bld.add("* Web API update single " + cls.getUName())
      bld.add("*/")

      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, fun)
      bld.add("public " + Utils.instance.getStyledClassName(cls.getUName()) +
              " Put" + Utils.instance.getStyledClassName(cls.getUName()) + "(int id);")
    end

    def process_dependencies(cls, bld, fun)
      dataClass = Utils.instance.get_data_class(cls)

      Utils.instance.requires_class_type(cls, dataClass, "class_jpa_entity")
      Utils.instance.requires_class_type(cls, dataClass, "tsql_data_store")
      Utils.instance.add_class_injection(cls, dataClass, "tsql_data_store")

      cls.addUse("org.springframework.http.*")
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      dataClass = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(dataClass.getUName() + " data store", Utils.instance.langProfile.variableNameStyle)
      className = Utils.instance.getStyledClassName(cls.getUName())

      params = Array.new
      idVar = cls.model.getIdentityVar()

      if idVar != nil
        params << "@RequestBody " + className + " item"
      end

      #bld.add "@CrossOrigin"
      bld.add '@PutMapping(path = "' + Utils.instance.getStyledUrlName(cls.getUName()) + '",'
      bld.iadd "consumes = MediaType.APPLICATION_JSON_VALUE, "
      bld.iadd "produces = MediaType.APPLICATION_JSON_VALUE)"

      bld.startFunction("public ResponseEntity<" + className +
                        "> Put" + className +
                        "(" + params.join(", ") + ")")

      bld.add(Utils.instance.getStyledClassName(cls.getUName()) + " savedItem = " + dataStoreName + ".saveAndFlush(item);")
      # bld.startBlock "if (savedItem == null)"
      # bld.add 'throw new Exception("");'
      # bld.endBlock

      bld.add "return new ResponseEntity<" + className + ">(savedItem, HttpStatus.CREATED);"

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodWebApiUpdate.new)