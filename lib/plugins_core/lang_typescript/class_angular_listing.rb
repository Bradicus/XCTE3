require "plugins_core/lang_typescript/class_base.rb"
require "include_util"

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

    def getUnformattedClassName(cls)
      return cls.getUName() + " component"
    end

    def getFileName(cls)
      if cls.featureGroup != nil
        Utils.instance.getStyledFileName(cls.getUName() + ".component")
      else
        Utils.instance.getStyledFileName(cls.getUName() + ".component")
      end
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

      IncludeUtil.init("class_angular_data_store_service").wModel(cls.model).addTo(cls)

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

      filePart = Utils.instance.getStyledFileName(cls.getUName())

      clsVar = CodeNameStyling.getStyled(getUnformattedClassName(cls), Utils.instance.langProfile.variableNameStyle)

      standardClassName = Utils.instance.getStyledClassName(cls.model.name)
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

      constructorParams = Array.new
      userServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_store_service")
      Utils.instance.addParamIfAvailable(constructorParams, userServiceVar)
      constructorParams.push("private route: ActivatedRoute")
      bld.startFunctionParamed("constructor", constructorParams)

      bld.endBlock

      bld.separate
      bld.startBlock("ngOnInit()")

      bld.add("this.items = " + "this." + Utils.instance.getStyledVariableName(userServiceVar) + ".listing();")

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
      render_functions(cls, bld)

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularListing.new)
