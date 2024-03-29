require "plugins_core/lang_typescript/class_angular_component"
require "plugins_core/lang_typescript/component_config"
require "include_util"

##
# Class:: ClassAngularReactiveEdit
#
module XCTETypescript
  class ClassAngularReactiveEdit < ClassAngularComponent
    def initialize
      super

      @name = "class_angular_reactive_edit"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + " component"
    end

    def get_file_name(cls)
      Utils.instance.get_styled_file_name(cls.get_u_name + ".component")
    end

    def getFilePath(cls)
      cls.namespace.get("/")
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(cls.get_u_name + ".component")
      bld.lfExtension = Utils.instance.get_extension("body")
      # render_file_comment(cls, bld)
      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "Component, OnInit, Input")
      cls.addInclude("@angular/common", "CommonModule")
      cls.addInclude("@angular/forms", "ReactiveFormsModule, FormControl, FormGroup, FormArray, Validators")

      cls.addInclude("@angular/router", "ActivatedRoute, Router")

      cls.addInclude("rxjs", "Observable, of", "lib")

      cls.addInclude("shared/dto/model/" + Utils.instance.get_styled_file_name(cls.model.name),
                     Utils.instance.get_styled_class_name(cls.model.name))

      IncludeUtil.init("class_angular_data_store_service").wModel(cls.model).addTo(cls)
      IncludeUtil.init("class_angular_data_gen_service").wModel(cls.model).addTo(cls)
      IncludeUtil.init("class_angular_data_map_service").wModel(cls.model).addTo(cls)

      each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var)
          cls.addInclude("shared/dto/model/" + Utils.instance.get_styled_file_name(var.getUType),
                         Utils.instance.get_styled_class_name(var.getUType))
        end
        if !var.selectFrom.nil?
          optVar = Utils.instance.getOptionsVarFor(var)
          cls.addInclude("shared/dto/model/" + Utils.instance.get_styled_file_name(optVar.getUType),
                         Utils.instance.get_styled_class_name(optVar.getUType))

          bCls = ClassModelManager.findClass(cls.model.name, "class_standard")
          if !bCls.nil?
            optStoreVar = Utils.instance.create_var_for(bCls, "class_angular_data_store_service")
            Utils.instance.try_add_include_for_var(bCls, optVar, "class_angular_data_store_service")
            Utils.instance.try_add_include_for_var(cls, optVar, "class_angular_data_store_service")
          end
        end
      }))

      cls.addInclude("shared/paging/filtered-page-resp-tpl", "FilteredPageRespTpl")
      cls.addInclude("shared/paging/filtered-page-req-tpl", "FilteredPageReqTpl")

      super
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      bld.add

      selectorName = Utils.instance.get_styled_file_name(cls.get_u_name)
      filePart = Utils.instance.get_styled_file_name(cls.get_u_name)

      clsVar = CodeNameStyling.getStyled(cls.get_u_name + " form", Utils.instance.langProfile.variableNameStyle)
      storeServiceVar = Utils.instance.create_var_for(cls, "class_angular_data_store_service")
      dataGenServiceVar = Utils.instance.create_var_for(cls, "class_angular_data_gen_service")
      userPopulateServiceVar = Utils.instance.create_var_for(cls, "class_angular_data_map_service")

      storeServiceVar.visibility = "private"
      dataGenServiceVar.visibility = "private"
      userPopulateServiceVar.visibility = "private"

      bld.render_component_declaration(ComponentConfig.new
        .w_selector_name(selectorName)
        .w_file_part(filePart)
        .w_imports(["CommonModule, ReactiveFormsModule"]))

      bld.separate

      bld.start_block("export class " + get_class_name(cls) + " implements OnInit ")
      bld.add("item: " + Utils.instance.get_styled_class_name(cls.model.name) + " = new " + Utils.instance.get_styled_class_name(cls.model.name) + "();")
      bld.separate

      # Generate class variables
      process_var_group(cls, bld, cls.model.varGroup)

      # Generate any selection list variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.selectFrom.nil?
          optVar = Utils.instance.getOptionsVarFor(var)
          bld.add(Utils.instance.get_var_dec(optVar))
          reqVar = Utils.instance.getOptionsReqVarFor(var)
          bld.add(Utils.instance.get_var_dec(reqVar))
        end
      }))

      bld.separate

      inst_fun = CodeStructure::CodeElemFunction.new(cls)

      constructorParams = inst_fun.parameters.vars
      Utils.instance.add_param_if_available(constructorParams, storeServiceVar)
      Utils.instance.add_param_if_available(constructorParams, dataGenServiceVar)
      Utils.instance.add_param_if_available(constructorParams, userPopulateServiceVar)

      # Generate any selection list variable parameters for data stores
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.selectFrom.nil?
          optVar = Utils.instance.getOptionsVarFor(var)
          optCls = ClassModelManager.findClass(var.selectFrom, "class_standard")
          if optVar.nil?
            Log.error("No options var for var: " + var.name)
          elsif optCls.nil?
            Log.error("No standard class for var: " + var.name)
          else
            dataStoreOptServiceVar = Utils.instance.create_var_for(optCls, "class_angular_data_store_service", "private")
            if !dataStoreOptServiceVar.nil?
              Utils.instance.add_param_if_available(constructorParams, dataStoreOptServiceVar)
            else
              Log.error("couldn't find data store service for: " + var.name)
            end
          end
        end
      }))

      constructorParams.push(CodeStructure::CodeElemVariable.new(nil).init_as_param("route", "ActivatedRoute", "private"))
      constructorParams.push(CodeStructure::CodeElemVariable.new(nil).init_as_param("router", "Router", "private"))

      bld.start_function("constructor", inst_fun)
      bld.end_block

      bld.separate
      bld.start_block("ngOnInit()")
      bld.add("this.route.paramMap.subscribe(params => {")
      bld.indent
      bld.add("let idVal = params.get('id');")
      idVar = cls.model.getFilteredVars(->(var) { var.name == "id" })
      if Utils.instance.is_numeric?(idVar[0])
        bld.add("this.item.id = idVal !== null ? parseInt(idVal) : 0;")
      else
        bld.add("this.item.id = idVal !== null ? idVal : '';")
      end

      bld.separate

      bld.start_block("if (!this.item?.id)")

      bld.add("this.item = new " + Utils.instance.get_styled_class_name(cls.model.name) + ";")
      bld.add "this.populate();"
      # bld.add("this." + Utils.instance.get_styled_variable_name(dataGenServiceVar) + ".initData(this.item);")
      bld.mid_block "else"
      bld.start_block "this." + Utils.instance.get_styled_variable_name(storeServiceVar) + ".detail(this.item.id).subscribe(data => {"
      bld.add "this.item = data;"
      bld.add "this.populate();"
      bld.end_block "});"
      bld.end_block
      bld.unindent
      bld.add("});")

      # Load any selection lists needed
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.selectFrom.nil?
          optVar = Utils.instance.getOptionsVarFor(var)
          reqVar = Utils.instance.getOptionsReqVarFor(var)
          optCls = ClassModelManager.findClass(var.selectFrom, "class_standard")
          if optVar.nil?
            Log.error("No options var for var: " + var.name)
          elsif optCls.nil?
            Log.error("No standard class for var: " + var.name)
          else
            dataStoreOptServiceVar = Utils.instance.create_var_for(optCls, "class_angular_data_store_service")
            if !dataStoreOptServiceVar.nil?
              bld.add("this." + Utils.instance.get_styled_variable_name(optVar) + " = this." +
                      Utils.instance.get_styled_variable_name(dataStoreOptServiceVar) + ".listing(this." + Utils.instance.get_styled_variable_name(reqVar) + ");")
            else
              Log.error("No class_angular_data_store_service variable for class: " + var.name)
            end
          end
        end
      }))

      bld.separate
      bld.add("this.populate();")
      bld.end_block

      bld.separate
      bld.start_block("onSubmit()")
      bld.add "this." + clsVar + ".markAllAsTouched();"
      bld.start_block("if (!this." + clsVar + ".invalid)")
      if idVar[0].getUType.downcase == "string" || idVar[0].getUType.downcase == "guid"
        bld.start_block("if (this." + clsVar + ".controls['id'].value?.length === 0)")
      else
        bld.start_block("if (this." + clsVar + ".controls['id'].value === null || !(this." + clsVar + ".controls['id'].value > 0))")
      end
      bld.start_block("this." + Utils.instance.get_styled_variable_name(storeServiceVar) + ".create(this." + clsVar + ".value).subscribe(newItem => ")
      listingSpec = cls.model.findClassSpecByPluginName("class_angular_listing")
      listingPlugin = XCTEPlugin.findClassPlugin("typescript", "class_angular_listing")
      if listingSpec != nil && listingPlugin != nil
        listPath = listingPlugin.get_full_route(listingSpec, "listing")
        bld.add 'this.router.navigate(["' + listPath.split("/").drop(1).unshift("/").join('","') + '"]);'
      else
        editPlugin = XCTEPlugin.findClassPlugin("typescript", "class_angular_reactive_edit")
        editPath = editPlugin.get_full_route(cls, "edit")

        if editPath != nil
          bld.add 'this.router.navigate(["' + editPath.split("/").drop(1).unshift("/").join('","') + '", newItem.id]);'
        else
          bld.add "this.item = newItem;"
        end
      end
      bld.end_block ");"
      bld.mid_block("else")
      bld.start_block("this." + Utils.instance.get_styled_variable_name(storeServiceVar) + ".update(this." + clsVar + ".value).subscribe(newItem => ")
      bld.add "this.item = newItem;"
      bld.end_block ");"
      bld.end_block
      bld.end_block
      bld.end_block

      bld.separate
      bld.start_block("onExit()")
      bld.end_block

      render_functions(cls, bld)

      bld.end_block
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      clsVar = CodeNameStyling.getStyled(cls.get_u_name + " form", Utils.instance.langProfile.variableNameStyle)
      bld.add(clsVar + " = ")

      Utils.instance.renderReactiveFormGroup(cls, bld, vGroup, false)
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularReactiveEdit.new)
