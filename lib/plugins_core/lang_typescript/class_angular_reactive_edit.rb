require "plugins_core/lang_typescript/class_base.rb"

##
# Class:: ClassAngularComponent
#
module XCTETypescript
  class ClassAngularComponent < ClassBase
    def initialize
      @name = "class_angular_reactive_edit"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " view component"
    end

    def getFileName(cls)
      Utils.instance.getStyledFileName(cls.getUName() + " view.component")
    end

    def getFilePath(cls)
      return cls.namespace.get("/")
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName() + " view" + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, bld)
      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "Component, OnInit, Input")
      cls.addInclude("@angular/forms", "ReactiveFormsModule, FormControl, FormGroup, FormArray")
      cls.addInclude("@angular/router", "ActivatedRoute")

      cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(cls.model.name), Utils.instance.getStyledClassName(cls.model.name))

      cls.addInclude("shared/services/" + Utils.instance.getStyledFileName(cls.model.name + " service"), Utils.instance.getStyledClassName(cls.model.name + " service"))
      if cls.model.findClassPlugin("class_angular_datagen_service") != nil
        cls.addInclude("shared/services/" + Utils.instance.getStyledFileName(cls.model.name + " faker service"), Utils.instance.getStyledClassName(cls.model.name + " faker service"))
      end

      if cls.model.findClassPlugin("class_angular_datamap_service") != nil
        cls.addInclude("shared/services/" + Utils.instance.getStyledFileName(cls.model.name + " form populate service"), Utils.instance.getStyledClassName(cls.model.name + " form populate service"))
      end

      super

      # Generate class variables
      for group in cls.model.groups
        process_var_dependencies(cls, bld, group)
      end
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.add

      selectorName = Utils.instance.getStyledFileName(cls.getUName() + " view")
      filePart = Utils.instance.getStyledFileName(cls.getUName() + " view")

      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      userServiceVar = Utils.instance.createVarFor(cls, "class_angular_datastore_service")
      fakerUserServiceVar = Utils.instance.createVarFor(cls, "class_angular_datagen_service")
      userPopulateServiceVar = Utils.instance.createVarFor(cls, "class_angular_datamap_service")

      bld.add("@Component({")
      bld.indent
      bld.add("selector: 'app-" + selectorName + "',")
      bld.add("templateUrl: './" + filePart + ".component.html',")
      bld.add("styleUrls: ['./" + filePart + ".component.css']")
      bld.unindent
      bld.add("})")

      bld.add

      bld.startBlock("export class " + getClassName(cls) + " implements OnInit ")
      bld.add("enableEdit: boolean = false;")
      bld.add("@Input() item: " + Utils.instance.getStyledClassName(cls.model.name) + " = {} as " + Utils.instance.getStyledClassName(cls.model.name) + ";")
      bld.separate

      # Generate class variables
      for group in cls.model.groups
        process_var_group(cls, bld, group)
        bld.sameLine(";")
      end

      bld.separate

      constructorParams = Array.new
      Utils.instance.addParamIfAvailable(constructorParams, userServiceVar)
      Utils.instance.addParamIfAvailable(constructorParams, fakerUserServiceVar)
      Utils.instance.addParamIfAvailable(constructorParams, userPopulateServiceVar)
      constructorParams.push("private route: ActivatedRoute")

      bld.startBlock("constructor(" + constructorParams.join(", ") + ")")
      bld.endBlock

      bld.separate
      bld.startBlock("ngOnInit()")
      bld.add("this.route.paramMap.subscribe(params => {")
      bld.iadd("let idVal = params.get('id');")
      idVar = cls.model.getFilteredVars(lambda { |var| var.name == "id" })
      if (Utils.instance.isNumericPrimitive(idVar[0]))
        bld.iadd("this.item.id = idVal !== null ? parseInt(idVal) : 0;")
      else
        bld.iadd("this.item.id = idVal !== null ? idVal : '';")
      end
      bld.add("});")
      bld.add("this.route.data.subscribe(data => {")
      #bld.iadd("enableEdit = data.enableEdit;")
      bld.iadd("console.log(data);")
      bld.add("});")

      bld.separate
      bld.add("this.populate();")
      bld.endBlock

      bld.add
      bld.startBlock("onSubmit()")
      if (idVar[0].getUType().downcase() == "string")
        bld.startBlock("if (this." + clsVar + ".controls['id'].value?.length === 0)")
      else
        bld.startBlock("if (this." + clsVar + ".controls['id'].value === null || this." + clsVar + ".controls['id'].value > 0)")
      end
      bld.add("this." + Utils.instance.getStyledVariableName(userServiceVar) + ".create(this." + clsVar + ".value);")
      bld.midBlock("else")
      bld.add("this." + Utils.instance.getStyledVariableName(userServiceVar) + ".update(this." + clsVar + ".value);")
      bld.endBlock
      bld.endBlock

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.endBlock
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      bld.add(clsVar + " = ")

      Utils.instance.getFormgroup(cls, bld, vGroup)
    end

    def process_var_dependencies(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !Utils.instance.isPrimitive(var)
            varCls = Classes.findVarClass(var)
            fPath = Utils.instance.getStyledFileName(var.getUType() + " view")
            #cls.addInclude(varCls.path + "/" + fPath + "/" + fPath + ".component", Utils.instance.getStyledClassName(var.getUType() + " view component"))
            cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(var.getUType()), Utils.instance.getStyledClassName(var.getUType()))
          end
        end
      end

      for grp in vGroup.groups
        process_var_dependencies(cls, bld, grp)
      end
    end

    def process_function(cls, bld, fun)
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
          if templ != nil
            bld.separate
            templ.get_definition(cls, bld)
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        else # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("typescript", "method_empty")
          if templ != nil
            bld.separate
            templ.get_definition(fun, cfg)
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularComponent.new)
