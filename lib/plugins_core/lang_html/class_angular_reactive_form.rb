##
# Class:: ClassAngularReactiveForm
#
module XCTEHtml
  class ClassAngularReactiveForm < XCTEPlugin
    def initialize
      @name = "class_angular_reactive_form"
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
      bld.lfName = Utils.instance.getStyledFileName(cls.model.name + " edit" + ".component")
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

      bld.startBlock('<div [formGroup]="' + CodeNameStyling.getStyled(getUnformattedClassName(cls) + " form", Utils.instance.langProfile.variableNameStyle) + '">')
      # Generate class variables
      for group in cls.model.groups
        process_var_group(cls, cfg, bld, group)
      end

      bld.endBlock("</div>")

      bld.add
    end

    # process variable group
    def process_var_group(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if Utils.instance.isPrimitive(var)
            varName = Utils.instance.getStyledVariableName(var)
            prefix = CodeNameStyling.getStyled(getUnformattedClassName(cls), Utils.instance.langProfile.variableNameStyle)
            bld.add('<label for="' + prefix + "-" + varName + '">' + var.getDisplayName() + "</label>")
            bld.add('<input id="' + prefix + "-" + varName + '" [formControlName]="' + varName + '" [type]="' + Utils.instance.getInputType(var) + '">')
          else
            bld.add("<app-" + Utils.instance.getStyledFileName(var.getUType()) + ">" +
                    "</app-" + Utils.instance.getStyledFileName(var.getUType) + ">")
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

XCTEPlugin::registerPlugin(XCTEHtml::ClassAngularReactiveForm.new)
