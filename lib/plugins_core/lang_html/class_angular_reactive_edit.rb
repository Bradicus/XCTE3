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
        bld.add('<button type="button" class="btn btn-primary" (click)="populateRandom()">Populate</button>')

        bld.add('<button type="button" class="btn btn-primary" (click)="onSubmit()">Save</button>')
        bld.add('<button type="button" class="btn btn-primary" (click)="onExit()">Cancel</button>')
      else
        bld.startBlock('<div [formGroup]="' + formName + '">')
      end

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).
        wVarCb(lambda { |var|
        if Utils.instance.isPrimitive(var) && !var.hasMultipleItems()
          render_field(cls, bld, var, nil)
        else
          if (!var.hasMultipleItems())
            vName = Utils.instance.getStyledVariableName(var)
            bld.startBlock('<fieldset formGroupName="' + vName + '">')
            bld.add("<legend>" + var.getDisplayName() + "</legend>")

            bld.add('<div class="row">')

            varCls = Classes.findVarClass(var, "standard")

            eachVar(uevParams().wCls(varCls).wBld(bld).wSeparate(true).
              wVarCb(lambda { |innerVar|
              render_field(cls, bld, innerVar, vName)
            }))

            bld.add("</div>")
            bld.endBlock("</fieldset>")
          else
            vName = Utils.instance.getStyledVariableName(var)
            # List of primitive "ids" linked to an options list
            if Utils.instance.isPrimitive(var) && var.selectFrom != nil
              optVar = cls.findVar(var.selectFrom)
              optVarName = Utils.instance.getStyledVariableName(optVar)
              TableUtil.instance.render_sel_option_table(bld, var, optVar, "item." + vName, vName + "Item")
            # Not an options list, just a reglar array of data
            elsif !var.isOptionsList
              varCls = Classes.findVarClass(var)
              if (varCls == nil)
                puts "Unable to find variable call " + var.getUType()
              end

              TableUtil.instance.render_table(varCls, bld, "item." + vName, vName + "Item")
            end
          end
        end
      }).
        wBeforeGroupCb(lambda { |innerVar|
        bld.add('<div class="row">')
        bld.indent
      }).
        wAfterGroupCb(lambda { |innerVar|
        bld.unindent
        bld.add("</div>")
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
      divClasses = []
      if (cls.genCfg.usesFramework("bootstrap"))
        labelClasses << "form-label"
        inputClasses << "form-control"
        if (var.name.downcase == "id")
          labelClasses << "visually-hidden"
          inputClasses << "visually-hidden"
        else
          divClasses << "col-md-3"
        end
      end

      labelCss = getClassDec(labelClasses)
      inputCss = getClassDec(inputClasses)
      divCss = getClassDec(divClasses)

      if (varPrefix != nil)
        varId = varPrefix + "-" + varName
      else
        varId = varName
      end

      if !var.isOptionsList
        bld.startBlock("<div" + divCss + ">")
        bld.add("<label" + labelCss + ' for="' + varId + '" >' + var.getDisplayName() + "</label>")
        if var.selectFrom != nil
          itemName = varName + 'Item'
          bld.add("<select" + inputCss + ' id="' + varId + '" formControlName="' + varName + '">')
          bld.iadd('<option *ngFor="let '+ itemName + ' of ' + varName + 'value="' + itemName + '.id">{{' + itemName + '.name}}</option>')
          bld.add("</select>")
        else
          bld.add("<input" + inputCss + ' id="' + varId + '" formControlName="' + varName + '" type="' + Utils.instance.getInputType(var) + '">')
        end
        bld.endBlock("</div>")
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
