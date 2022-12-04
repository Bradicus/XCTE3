require "plugins_core/lang_typescript/class_base.rb"

##
# Class:: ClassAngularListing
#
module XCTETypescript
  class ClassAngularListing < ClassBase
    def initialize
      @name = "class_angular_listing"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " listing component"
    end

    def getFileName(cls)
      Utils.instance.getStyledFileName(cls.getUName() + " listing.component")
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = getFileName(cls)
      bld.lfExtension = Utils.instance.getExtension("body")

      process_dependencies(cls, bld)

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "Component, OnInit")
      cls.addInclude("@angular/router", "Routes, RouterModule, ActivatedRoute")
      cls.addInclude("rxjs", "Observable", "lib")
      cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(cls.model.name), Utils.instance.getStyledClassName(cls.model.name))
      cls.addInclude("shared/services/" + Utils.instance.getStyledFileName(cls.model.name + " service"), Utils.instance.getStyledClassName(cls.model.name + " service"))

      super
      # Generate class variables
      # for group in cls.model.groups
      #   process_var_dependencies(cls, bld, group)
      # end
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      render_dependencies(cls, bld)

      bld.add

      filePart = Utils.instance.getStyledFileName(cls.getUName() + " listing")

      clsVar = CodeNameStyling.getStyled(getUnformattedClassName(cls), Utils.instance.langProfile.variableNameStyle)
      standardClassName = Utils.instance.getStyledClassName(cls.getUName())
      routeName = Utils.instance.getStyledFileName(cls.getUName())

      bld.add("@Component({")
      bld.indent
      bld.add("selector: 'app-" + filePart + "',")
      bld.add("templateUrl: './" + filePart + ".component.html',")
      bld.add("styleUrls: ['./" + filePart + ".component.css']")
      bld.unindent
      bld.add("})")

      bld.separate

      bld.startBlock("export class " + getClassName(cls) + " implements OnInit ")

      bld.add("public items: Observable<" + standardClassName + "[]> = new Observable<" + standardClassName + "[]>;")

      bld.separate

      bld.startBlock("constructor(private service: " + standardClassName + "Service, private route: ActivatedRoute)")
      bld.endBlock

      bld.separate
      bld.startBlock("ngOnInit()")
      bld.add("this.items = " + "this.service.listing();")
      bld.endBlock

      bld.separate

      # bld.startBlock("onView()")
      # bld.add("this.router.navigate(['/" + routeName + "/" + routeName + "-view']);")
      # bld.endBlock

      bld.separate

      # bld.startBlock("onDelete(item: " + standardClassName + ")")
      # bld.add("this.service.delete(item.id);")
      # bld.endBlock

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.endClass
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add(Utils.instance.getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.sameLine(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
        for group in vGroup.groups
          process_var_group(cls, bld, group)
        end
      end
    end

    def process_function(cls, bld, fun)
      bld.separate

      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
          if templ != nil
            bld.add(templ.get_definition(cls, cfg))
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        else # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("typescript", "method_empty")
          if templ != nil
            bld.add(templ.get_definition(fun, cfg))
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularListing.new)
