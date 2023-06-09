##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "plugins_core/lang_java/method_web_api_base"
require "code_name_styling.rb"
require "plugins_core/lang_java/utils.rb"

module XCTEJava
  class MethodWebApiUpdate < MethodWebApiBase
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

    def get_body(cls, bld, fun)
      conDef = String.new
      dataClass = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(dataClass.getUName() + " data store", Utils.instance.langProfile.variableNameStyle)
      className = Utils.instance.getStyledClassName(cls.getUName())
      mapperName = "mapper"

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

      bld.add "var dataItem = " + dataStoreName + ".findById(item.id);"
      bld.separate

      bld.startBlock "if (dataItem.isPresent())"
      if cls.dataClass != nil
        bld.add mapperName + ".map(item, dataItem.get());"
        bld.add(Utils.instance.getStyledClassName(dataClass.getUName()) + " savedItem = " + dataStoreName + ".saveAndFlush(dataItem.get());")
        bld.add "var returnItem = new " + className + "();"
        bld.add mapperName + ".map(savedItem, returnItem);"

        bld.add "return new ResponseEntity<" + className + ">(returnItem, HttpStatus.CREATED);"
      else
        bld.add(Utils.instance.getStyledClassName(dataClass.getUName()) + " savedItem = " + dataStoreName + ".saveAndFlush(item);")
        bld.add "return new ResponseEntity<" + className + ">(savedItem, HttpStatus.CREATED);"
      end

      bld.midBlock("else")
      bld.add "return null;"
      bld.endBlock

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodWebApiUpdate.new)
