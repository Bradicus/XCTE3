##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "data list display edit" classes
# for displaying an editor for list item data

module XCTEPhp
  class MethodDataListDisplayEdit < XCTEPlugin
    def initialize
      @name = "method_data_list_display_edit"
      @language = "php"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    def get_definition(codeClass, cfg, outCode)
      
      outCode.indent

      outCode.add("/**")
      outCode.add("* Diplays editor html for this classes data ")
      outCode.add("*/")

      outCode.add("public function diplayEdit($curCellIndex, $tabbed)")
      outCode.add("{");

      outCode.indent
	  
      if ($tabbed != true)
          outCode.add('print("    <table id="' << codeClass.name << '">);')
      end

      # Display tables
      for grp in codeClass.groups
        if ($tabbed == true)
          outCode.add('print("    <table id="' << grp.name << '">);')
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
          outCode.add('print("    </table>);')
        end
        
      end

      if ($tabbed == true)
        outCode.add('print("    </ul>);')
      end
      
      outCode.unindent
      outCode.add("}")
      outCode.unindent

      return(outCode);
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodDataListDisplayEdit.new)
