##
# Class:: ClassAngularReactiveEdit
#
module XCTEHtml
  class ClassAngularReactiveEdit < ClassBase
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

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName() + " view.component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      nested = (cls.xmlElement.attributes["nested"] == "true")
      formName = CodeNameStyling.getStyled(getUnformattedClassName(cls) + " form", Utils.instance.langProfile.variableNameStyle)

      if (!nested)
        bld.add("<h2>" + cls.model.name.capitalize + " view</h2>")
        bld.startBlock('<form [formGroup]="' + formName + '" (ngSubmit)="onSubmit()">')
        bld.add('<button (click)="populateRandom()">Populate</button>')
      else
        bld.startBlock('<div [formGroup]="' + formName + '">')
      end

      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
        if Utils.instance.isPrimitive(var)
          render_field(cls, bld, var, nil)
        else
          if (!var.hasMultipleItems())
            vName = Utils.instance.getStyledVariableName(var)
            bld.startBlock('<fieldset formGroupName="' + vName + '">')
            bld.add("<legend>" + var.getDisplayName() + "</legend>")

            varCls = Classes.findVarClass(var, "standard")

            Utils.instance.eachVar(UtilsEachVarParams.new(varCls, bld, true, lambda { |innerVar|
              render_field(cls, bld, innerVar, vName)
            }))

            bld.endBlock("</fieldset>")
          end
        end
      }))

      if (!nested)
        bld.endBlock("</form>")
      else
        bld.endBlock("</div>")
      end

      bld.add
    end

    def render_field(cls, bld, var, varPrefix)
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

      if (varPrefix != nil)
        varId = varPrefix + "-" + varName
      else
        varId = varName
      end

      bld.startBlock("<div>")
      bld.add("<label" + labelCss + ' for="' + varId + '" >' + var.getDisplayName() + "</label>")
      bld.add("<input" + inputCss + ' id="' + varId + '" formControlName="' + varName + '" type="' + Utils.instance.getInputType(var) + '">')
      bld.endBlock("</div>")
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
