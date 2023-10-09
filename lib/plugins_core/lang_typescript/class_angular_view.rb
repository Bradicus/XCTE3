require "plugins_core/lang_typescript/class_base.rb"
require "include_util"

##
# Class:: ClassAngularReactiveEdit
#
module XCTETypescript
  class ClassAngularReactiveEdit < ClassBase
    def initialize
      @name = "class_angular_view"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " component"
    end

    def getFileName(cls)
      Utils.instance.getStyledFileName(cls.getUName() + ".component")
    end

    def getFilePath(cls)
      return cls.namespace.get("/")
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName() + ".component")
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

      IncludeUtil.init("class_angular_data_store_service").wModel(cls.model).addTo(cls)
      IncludeUtil.init("class_angular_data_gen_service").wModel(cls.model).addTo(cls)
      IncludeUtil.init("class_angular_data_map_service").wModel(cls.model).addTo(cls)

      eachVar(UtilsEachVarParams.new().wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.isPrimitive(var)
          cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(var.getUType()), Utils.instance.getStyledClassName(var.getUType()))
        end
        if var.selectFrom != nil
          optVar = Utils.instance.getOptionsVarFor(var)
          cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(optVar.getUType()),
                         Utils.instance.getStyledClassName(optVar.getUType()))

          bCls = ClassModelManager.findClass(cls.model.name, "ts_interface")
          optStoreVar = Utils.instance.createVarFor(bCls, "class_angular_data_store_service")
          Utils.instance.tryAddIncludeForVar(bCls, optVar, "class_angular_data_store_service")
          Utils.instance.tryAddIncludeForVar(cls, optVar, "class_angular_data_store_service")
        end
      }))

      cls.addInclude("shared/paging/filtered-page-resp-tpl", "FilteredPageRespTpl")
      cls.addInclude("shared/paging/filtered-page-req-tpl", "FilteredPageReqTpl")

      super
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.add

      selectorName = Utils.instance.getStyledFileName(cls.getUName())
      filePart = Utils.instance.getStyledFileName(cls.getUName())

      clsVar = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      storeServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_store_service")
      dataGenServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_gen_service")
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
      bld.add("public item: " + Utils.instance.getStyledClassName(cls.model.name) + " = {} as " + Utils.instance.getStyledClassName(cls.model.name) + ";")
      bld.separate

      # Generate class variables
      process_var_group(cls, bld, cls.model.varGroup)

      # Generate any selection list variables
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.selectFrom != nil
          optVar = Utils.instance.getOptionsVarFor(var)
          bld.add(Utils.instance.getVarDec(optVar))
          reqVar = Utils.instance.getOptionsReqVarFor(var)
          bld.add(Utils.instance.getVarDec(reqVar))
        end
      }))

      bld.separate

      constructorParams = Array.new
      Utils.instance.addParamIfAvailable(constructorParams, storeServiceVar)
      Utils.instance.addParamIfAvailable(constructorParams, dataGenServiceVar)
      Utils.instance.addParamIfAvailable(constructorParams, userPopulateServiceVar)

      # Generate any selection list variable parameters for data stores
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.selectFrom != nil
          optVar = Utils.instance.getOptionsVarFor(var)
          optCls = ClassModelManager.findClass(var.selectFrom, "ts_interface")
          if optVar == nil
            Log.error("No options var for var: " + var.name)
          elsif optCls == nil
            Log.error("No ts_interface class for var: " + var.name)
          else
            dataStoreOptServiceVar = Utils.instance.createVarFor(optCls, "class_angular_data_store_service")
            if dataStoreOptServiceVar != nil
              Utils.instance.addParamIfAvailable(constructorParams, dataStoreOptServiceVar)
            else
              Log.error("couldn't find data store service for: " + var.name)
            end
          end
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
      idVar = cls.model.getFilteredVars(lambda { |var| var.name == "id" })
      if (Utils.instance.isNumericPrimitive(idVar[0]))
        bld.add("this.item.id = idVal !== null ? parseInt(idVal) : 0;")
      else
        bld.add("this.item.id = idVal !== null ? idVal : '';")
      end

      bld.separate

      bld.startBlock("if (!this.item?.id)")

      bld.add("this.item = {} as " + Utils.instance.getStyledClassName(cls.model.name) + ";")
      bld.add("this." + Utils.instance.getStyledVariableName(dataGenServiceVar) + ".initData(this.item);")
      bld.midBlock 'else'
      bld.startBlock "this." + Utils.instance.getStyledVariableName(storeServiceVar) + ".detail(this.item.id).subscribe(data => {"
      bld.add "this.item = data;"
      bld.add "this.populate();"
      bld.endBlock "});"
      bld.endBlock 
      bld.unindent
      bld.add("});")

      # Load any selection lists needed
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.selectFrom != nil
          optVar = Utils.instance.getOptionsVarFor(var)
          reqVar = Utils.instance.getOptionsReqVarFor(var)
          optCls = ClassModelManager.findClass(var.selectFrom, "ts_interface")
          if optVar == nil
            Log.error("No options var for var: " + var.name)
          elsif optCls == nil
            Log.error("No ts_interface class for var: " + var.name)
          else
            dataStoreOptServiceVar = Utils.instance.createVarFor(optCls, "class_angular_data_store_service")
            if dataStoreOptServiceVar != nil
              bld.add("this." + Utils.instance.getStyledVariableName(optVar) + " = this." +
                      Utils.instance.getStyledVariableName(dataStoreOptServiceVar) + ".listing(this." + Utils.instance.getStyledVariableName(reqVar) + ");")
            else
              Log.error("No class_angular_data_store_service variable for class: " + var.name)
            end
          end
        end
      }))

      bld.separate
      bld.add("this.populate();")
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
