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

      bld = SourceRenderer.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << rubyFile

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      for inc in cls.includesList
        bld.add("require '" + inc.path + inc.name + "." + Utils.instance.getExtension("body") + "'")
      end

      if !cls.includesList.empty?
        bld.add
      end

      if cls.hasAnArray
        bld.add  # If we declaired array size variables add a seperator
      end

      bld.startBlock('<div [formGroup]="' + Utils.instance.getStyledClassName(getUnformattedClassName(cls) + "form") + '">')
      # Generate class variables
      for group in vGroup.groups
        process_var_group(cls, cfg, bld, group)
      end

      bld.endBlock("</div>")

      bld.add
    end

    # process variable group
    def process_var_group(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          varName = Utils.instance.getStyledVariableName(var)
          bld.add('<label [attr.for]="' + varName + '">' + var.getDisplayName() + "</label>")
          bld.add('<input [formControlName]="' + varName + '"[type]="' + Utils.instance.getInputType(var) + '">')
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
