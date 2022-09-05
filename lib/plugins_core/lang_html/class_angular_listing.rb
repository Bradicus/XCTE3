##
# Class:: ClassAngularListing
#
module XCTEHtml
  class ClassAngularListing < XCTEPlugin
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

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls) + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      for inc in cls.includes
        bld.add("require '" + inc.path + inc.name + "." + Utils.instance.getExtension("body") + "'")
      end

      if !cls.includes.empty?
        bld.add
      end

      if cls.model.hasAnArray
        bld.add  # If we declaired array size variables add a seperator
      end

      bld.startBlock('<table id="' + CodeNameStyling.getStyled(getUnformattedClassName(cls) + "", Utils.instance.langProfile.variableNameStyle) + '">')

      # Generate table header
      bld.startBlock("<thead>")
      bld.startBlock("<tr>")
      for group in cls.model.groups
        process_var_group_header(cls, cfg, bld, group)
      end
      bld.endBlock("</tr>")
      bld.endBlock("</thead>")

      # Generate table body
      bld.startBlock("<body>")
      bld.startBlock('<tr *ngFor="let item of itemList">')
      for group in cls.model.groups
        process_var_group_body(cls, cfg, bld, group)
      end
      bld.endBlock("</tr>")
      bld.endBlock("</body>")

      bld.endBlock("</table>")

      bld.add
    end

    # process variable group
    def process_var_group_header(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if Utils.instance.isPrimitive(var)
            varName = Utils.instance.getStyledVariableName(var)

            bld.add("<th>" + var.getDisplayName() + "</th>")
          end
        end
        for group in vGroup.groups
          process_var_group_header(cls, cfg, bld, group)
        end
      end
    end

    # process variable group
    def process_var_group_body(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if Utils.instance.isPrimitive(var)
            varName = Utils.instance.getStyledVariableName(var)

            bld.add("<td>{{item." + varName + "}}</td>")
          end
        end
        for group in vGroup.groups
          process_var_group_body(cls, cfg, bld, group)
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTEHtml::ClassAngularListing.new)
