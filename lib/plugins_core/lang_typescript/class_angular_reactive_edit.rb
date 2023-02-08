require "plugins_core/lang_typescript/class_base.rb"

##
# Class:: ClassAngularReactiveEdit
#
module XCTETypescript
  class ClassAngularReactiveEdit < ClassBase
    def initialize
      @name = "class_angular_reactive_edit"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " view component"
    end

    def getFileName(cls)
      Utils.instance.getStyledFileName(cls.getUName() + "-view.component")
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
      cls.addInclude("@angular/forms", "ReactiveFormsModule, FormControl, FormGroup, FormArray, Validators")
      cls.addInclude("@angular/router", "ActivatedRoute")
      cls.addInclude("rxjs", "Observable, of", "lib")

      cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(cls.model.name), Utils.instance.getStyledClassName(cls.model.name))

      Utils.instance.tryAddIncludeFor(cls, "class_angular_data_store_service")
      Utils.instance.tryAddIncludeFor(cls, "class_angular_data_gen_service")
      Utils.instance.tryAddIncludeFor(cls, "class_angular_data_map_service")

      eachVar(UtilsEachVarParams.new().wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.isPrimitive(var)
          cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(var.getUType()), Utils.instance.getStyledClassName(var.getUType()))
        end
        if var.selectFrom != nil
          optVar = Utils.instance.getOptionsVarFor(var)
          cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(optVar.getUType()),
                         Utils.instance.getStyledClassName(optVar.getUType()))

          optStoreVar = Utils.instance.createVarFor(cls, "class_angular_data_store_service")
          Utils.instance.tryAddIncludeForVar(cls, optVar, "class_angular_data_store_service")
        end
      }))

      super
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.add

      selectorName = Utils.instance.getStyledFileName(cls.getUName() + " view")
      filePart = Utils.instance.getStyledFileName(cls.getUName() + " view")

      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      userServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_store_service")
      dataGenUserServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_gen_service")
      userPopulateServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_map_service")

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
      process_var_group(cls, bld, cls.model.varGroup)

      # Generate any selection list variables
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.selectFrom != nil
          optVar = Utils.instance.getOptionsVarFor(var)
          bld.add(Utils.instance.getVarDec(optVar))
        end
      }))

      bld.separate

      constructorParams = Array.new
      Utils.instance.addParamIfAvailable(constructorParams, userServiceVar)
      Utils.instance.addParamIfAvailable(constructorParams, dataGenUserServiceVar)
      Utils.instance.addParamIfAvailable(constructorParams, userPopulateServiceVar)

      # Generate any selection list variable parameters for data stores
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.selectFrom != nil
          optVar = Utils.instance.getOptionsVarFor(var)
          optCls = Classes.findClass("ts_interface", var.selectFrom)
          dataStoreOptServiceVar = Utils.instance.createVarFor(optCls, "class_angular_data_store_service")
          Utils.instance.addParamIfAvailable(constructorParams, dataStoreOptServiceVar)
        end
      }))

      constructorParams.push("private route: ActivatedRoute")

      bld.startFunctionParamed("constructor", constructorParams)
      bld.endBlock

      bld.separate
      bld.startBlock("ngOnInit()")
      bld.add("this.route.paramMap.subscribe(params => {")
      bld.indent
      bld.add("let idVal = params.get('id');")
      bld.add("if (!this.item?.id) {")

      bld.iadd("this.item = {} as " + Utils.instance.getStyledClassName(cls.model.name) + ";")
      bld.iadd("this." + Utils.instance.getStyledVariableName(dataGenUserServiceVar) + ".initData(this.item);")
      bld.add("}")
      idVar = cls.model.getFilteredVars(lambda { |var| var.name == "id" })
      if (Utils.instance.isNumericPrimitive(idVar[0]))
        bld.add("this.item.id = idVal !== null ? parseInt(idVal) : 0;")
      else
        bld.add("this.item.id = idVal !== null ? idVal : '';")
      end
      bld.unindent
      bld.add("});")
      bld.add("this.route.data.subscribe(data => {")
      bld.indent
      bld.startBlock("if (data['enableEdit'])")
      bld.add("this.enableEdit = data['enableEdit'];")
      bld.endBlock
      bld.unindent
      bld.add("});")

      # Load any selection lists needed
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.selectFrom != nil
          optVar = Utils.instance.getOptionsVarFor(var)
          optCls = Classes.findClass("ts_interface", var.selectFrom)
          dataStoreOptServiceVar = Utils.instance.createVarFor(optCls, "class_angular_data_store_service")
          bld.add("this." + Utils.instance.getStyledVariableName(optVar) + " = this." + Utils.instance.getStyledVariableName(dataStoreOptServiceVar) + ".listing();")
        end
      }))

      bld.separate
      bld.add("this.populate();")
      bld.endBlock

      bld.separate
      bld.startBlock("onSubmit()")
      bld.startBlock("if (!this." + clsVar + ".invalid)")
      if (idVar[0].getUType().downcase() == "string" || idVar[0].getUType().downcase() == "guid")
        bld.startBlock("if (this." + clsVar + ".controls['id'].value?.length === 0)")
      else
        bld.startBlock("if (this." + clsVar + ".controls['id'].value === null || !(this." + clsVar + ".controls['id'].value > 0))")
      end
      bld.startBlock("this." + Utils.instance.getStyledVariableName(userServiceVar) + ".create(this." + clsVar + ".value).subscribe(newItem => ")
      bld.add "this.item = newItem;"
      bld.endBlock ");"
      bld.midBlock("else")
      bld.startBlock("this." + Utils.instance.getStyledVariableName(userServiceVar) + ".update(this." + clsVar + ".value).subscribe(newItem => ")
      bld.add "this.item = newItem;"
      bld.endBlock ");"
      bld.endBlock
      bld.endBlock
      bld.endBlock

      bld.separate
      bld.startBlock("onExit()")
      bld.endBlock

      render_functions(cls, bld)

      bld.endBlock
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      bld.add(clsVar + " = ")

      Utils.instance.getFormgroup(cls, bld, vGroup)
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularReactiveEdit.new)
