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
  class MethodWebApiRead < MethodWebApiBase
    def initialize
      super

      @name = "method_web_api_read_one"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      bld.add("/*")
      bld.add("* Web API get single " + cls.get_u_name)
      bld.add("*/")

      get_body(fp_params)
    end

    def get_declairation(cls, bld, _fun)
      bld.add("public " + Utils.instance.style_as_class(cls.get_u_name) +
              " Get" + Utils.instance.style_as_class(cls.get_u_name) + "(int id);")
    end

    def get_body(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      conDef = String.new
      dataClass = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(dataClass.get_u_name + " data store", Utils.instance.langProfile.variableNameStyle)
      mapperName = "mapper"

      params = []
      idVar = cls.model.getIdentityVar

      if !idVar.nil?
        params << '@PathVariable("' + Utils.instance.get_styled_variable_name(idVar) + '") ' + Utils.instance.get_param_dec(idVar)
      end

      bld.add('@GetMapping("' + Utils.instance.get_styled_url_name(cls.get_u_name) + '/{id}")')

      bld.start_function("public " + Utils.instance.style_as_class(cls.get_u_name) +
                         " Get" + Utils.instance.style_as_class(cls.get_u_name) +
                         "(" + params.join(", ") + ")")

      bld.add("var item = " + dataStoreName + ".findById(id);")
      bld.separate

      if !cls.data_class.nil?
        bld.start_block "if (item.isPresent())"
        bld.add "var mappedItem = new " + Utils.instance.style_as_class(cls.get_u_name) + "();"
        bld.add(mapperName + ".map(item.get(), mappedItem);")
        bld.add("return mappedItem;")
        bld.end_block

        bld.add "return null;"
      else
        bld.add("return item.get();")
      end

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodWebApiRead.new)
