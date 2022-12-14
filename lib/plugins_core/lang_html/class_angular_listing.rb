require "plugins_core/lang_html/class_base"

##
# Class:: ClassAngularListing
#
module XCTEHtml
  class ClassAngularListing < ClassBase
    def initialize
      @name = "class_angular_listing"
      @language = "html"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " listing"
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls) + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      if (cls.model.findClassModel("class_angular_reactive_edit"))
        bld.add('<button type="button" class="btn btn-primary" routerLink="/user/edit/0">New ' + cls.getUName() + "</button>")
      end

      bld.startBlock('<table class="table" id="' + CodeNameStyling.getStyled(getUnformattedClassName(cls) + "", Utils.instance.langProfile.variableNameStyle) + '">')

      # Generate table header
      bld.startBlock("<thead>")
      bld.startBlock("<tr>")

      process_var_group_header(cls, bld, cls.model.varGroup)

      bld.endBlock("</tr>")
      bld.endBlock("</thead>")

      # Generate table body
      bld.startBlock("<body>")
      bld.startBlock('<tr *ngFor="let item of items | async">')

      process_var_group_body(cls, bld, cls.model.varGroup)

      bld.add('<td><a class="button" routerLink="/user/view/{{item.id}}">View</a></td>')
      bld.add('<td><a class="button" routerLink="/user/edit/{{item.id}}">Edit</a></td>')
      bld.endBlock("</tr>")
      bld.endBlock("</body>")

      bld.endBlock("</table>")

      bld.add
    end

    # process variable group
    def process_var_group_header(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if Utils.instance.isPrimitive(var)
            varName = Utils.instance.getStyledVariableName(var)

            bld.add("<th>" + var.getDisplayName() + "</th>")
          end
        end
        for group in vGroup.varGroups
          process_var_group_header(cls, bld, group)
        end
      end
    end

    # process variable group
    def process_var_group_body(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if Utils.instance.isPrimitive(var)
            varName = Utils.instance.getStyledVariableName(var)

            bld.add("<td>{{item." + varName + "}}</td>")
          end
        end
        for group in vGroup.varGroups
          process_var_group_body(cls, bld, group)
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTEHtml::ClassAngularListing.new)
