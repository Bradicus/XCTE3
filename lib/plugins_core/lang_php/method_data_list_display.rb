##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "data list display" classes

module XCTEPhp
  class MethodDataListDisplay < XCTEPlugin
    def initialize
      @name = "method_data_list_display"
      @language = "php"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    def get_definition(codeClass, outCode)

      outCode.add("/**")
      outCode.add("* Diplays html for this classes data ")
      outCode.add("*/")

      outCode.startFuction("public function diplay($rowStart = 0, $rowEnd = 11)")

      for grp in codeClass.groups
        if ($tabbed == true)
          outCode.add('print("    <ul id="' << grp.name << '">);')
        else
          outCode.add('print("    <fieldset>"));')
          outCode.add('print("    <legend> ' << grp.name << ' </legend> "));')
        end

        for grpVar in grp.vars

          outCode.add('print("        <div>"."\"));')
          outCode.add('print("            ' << grpVar.name << '&nbsp;&nbsp; ");')
          outCode.add('print(\'            <input type="text" name="' << grpVar.name <<
                            '" id="t_' << grpVar.name << '_id" value="\'.' <<
                            '$itemList[$curCellIndex]->dataSet["' << grpVar.name << '"].\' ">\n\');')
          outCode.add('print("        </div>"."\"));')
        end

        if ($tabbed == true)
          outCode.add('print("    </ul>"));')
        else
          outCode.add('print("    </fieldset>"));')
        end

      end
	
	  outCode.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodDataListDisplay.new)
