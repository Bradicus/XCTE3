##
# Class:: ClassAngularReactiveEdit
#
module XCTEHtml
  class ClassAngularReactiveEdit < XCTEPlugin
    def initialize
      @name = "class_angular_reactive_edit"
      @language = "html"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName() + " edit.component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      nested = (cls.xmlElement.attributes["nested"] == "true")

      if (!nested)
        bld.add("<h2>" + cls.model.name.capitalize + " edit</h2>")
      end

      formName = CodeNameStyling.getStyled(getUnformattedClassName(cls) + " form", Utils.instance.langProfile.variableNameStyle)

      if (!nested)
        bld.startBlock('<form [formGroup]="' + formName + '" (ngSubmit)="onSubmit()">')
      else
        bld.startBlock("<div>")
      end

      # Generate class variables
      for group in cls.model.groups
        process_var_group(cls, cfg, bld, group)
      end

      if (!nested)
        bld.endBlock("</form>")
      else
        bld.endBlock("</div>")
      end

      bld.add
    end

    # process variable group
    def process_var_group(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if Utils.instance.isPrimitive(var)
            varName = Utils.instance.getStyledVariableName(var)
            labelClasses = []
            inputClasses = []
            if (cls.genCfg.usesFramework("bootstrap"))
              labelClasses << "form-label"
              inputClasses << "form-control"
              if (var.name.downcase == "id")
                labelClasses << "visually-hidden"
                inputClasses << "visually-hidden"
              end
            end

            labelCss = getClassDec(labelClasses)
            inputCss = getClassDec(inputClasses)

            bld.startBlock("<div>")
            bld.add("<label" + labelCss + ' for="' + varName + '" >' + var.getDisplayName() + "</label>")
            bld.add("<input" + inputCss + ' id="' + varName + '" formControlName="' + varName + '" type="' + Utils.instance.getInputType(var) + '">')
            bld.endBlock("</div>")
          else
            if (var.listType == nil)
              bld.add("<fieldset>")
              bld.add("<legend>" + var.getDisplayName() + "</legend>")
              bld.add("<app-" + Utils.instance.getStyledFileName(var.getUType() + " edit") + ">" +
                      "</app-" + Utils.instance.getStyledFileName(var.getUType() + " edit") + ">")
              bld.add("</fieldset>")
            end
          end
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.sameLine(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
        for group in vGroup.groups
          process_var_group(cls, cfg, bld, group)
        end
      end
    end

    def getClassDec(classList)
      if classList.length > 0
        return ' class="' + classList.join(" ") + '"'
      else
        return ""
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTEHtml::ClassAngularReactiveEdit.new)
