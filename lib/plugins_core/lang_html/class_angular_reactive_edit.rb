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
      return cls.model.name
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.getStyledFileName(cls.model.name + " edit.component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      if cls.model.hasAnArray
        bld.add  # If we declaired array size variables add a seperator
      end

      bld.startBlock('<form [formGroup]="' + Utils.instance.getStyledVariableName(getUnformattedClassName(cls) + " form") + '"  (ngSubmit)="onSubmit()">')
      # Generate class variables
      for group in cls.model.groups
        process_var_group(cls, cfg, bld, group)
      end

      bld.endBlock("</form>")

      bld.add
    end

    # process variable group
    def process_var_group(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if Utils.instance.isPrimitive(var)
            varName = Utils.instance.getStyledVariableName(var)
            bld.add('<label for="' + varName + '">' + var.getDisplayName() + "</label>")
            bld.add('<input id="' + varName + '" [formControlName]="' + varName + '" [type]="' + Utils.instance.getInputType(var) + '">')
          else
            bld.add("<app-" + Utils.instance.getStyledFileName(var.utype) + ">" +
                    "</app-" + Utils.instance.getStyledFileName(var.utype) + ">")
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
  end
end

XCTEPlugin::registerPlugin(XCTEHtml::ClassAngularReactiveEdit.new)
