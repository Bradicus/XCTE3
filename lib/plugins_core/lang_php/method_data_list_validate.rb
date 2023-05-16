##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates a validate function for this class's data

module XCTEPhp
  class MethodDataListValidate < XCTEPlugin
    def initialize
      @name = "method_data_list_validate"
      @language = "php"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_definition(listCodeClass, cfg)
      outCode.indent

      listInfo = XCTEPhp::Utils::getDataListInfo(listCodeClass.xmlElement)
      listPath = File.dirname(listCodeClass.path)

      codeClass = ClassPluginManager.findClass(codeClass.coreClass)

      # First get info for child class

      outCode.add("/**")
      outCode.add("* Validates this lists data")
      outCode.add("*/")

      outCode.add("public function validate()")
      outCode.add("{")

      outCode.indent

      outCode.add("$this->errors = array();")

      outCode.add("for ($i = 0; $i < count($this->itemList); $i++)")
      outCode.add("{")
      outCode.iadd(1, codeClass.coreClass << "Validator::validate($this->itemList[$i], $this->errors, $i);")
      outCode.add("}")

      outCode.unindent

      outCode.add("}")
      outCode.unindent
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodDataListValidate.new)
