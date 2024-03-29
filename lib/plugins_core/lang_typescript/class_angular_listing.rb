require "plugins_core/lang_typescript/class_angular_component"
require "include_util"

##
# Class:: ClassAngularListing
#
module XCTETypescript
  class ClassAngularListing < ClassAngularComponent
    def initialize
      super
      @name = "class_angular_listing"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = get_file_name(cls)
      bld.lfExtension = Utils.instance.get_extension("body")

      process_dependencies(cls, bld)

      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "Component, OnInit")
      cls.addInclude("@angular/common", "CommonModule")
      cls.addInclude("@angular/router", "Routes, RouterModule, ActivatedRoute")
      cls.addInclude("rxjs", "Observable", "lib")
      cls.addInclude("shared/dto/model/" + Utils.instance.get_styled_file_name(cls.model.name),
                     Utils.instance.get_styled_class_name(cls.model.name))

      cls.addInclude("shared/paging/filtered-page-req-tpl", "FilteredPageReqTpl")
      cls.addInclude("shared/paging/filtered-page-resp-tpl", "FilteredPageRespTpl")

      if cls.model.data_filter.has_search_filter?
        cls.addInclude("rxjs", "Subject, debounceTime, distinctUntilChanged", "lib")
      end

      IncludeUtil.init("class_angular_data_store_service").wModel(cls.model).addTo(cls)

      super
      # Generate class variables
      # for group in cls.model.groups
      #   process_var_dependencies(cls, bld, group)
      # end
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      render_dependencies(cls, bld)

      bld.add

      filePart = Utils.instance.get_styled_file_name(cls.get_u_name)

      clsVar = CodeNameStyling.getStyled(get_unformatted_class_name(cls), Utils.instance.langProfile.variableNameStyle)

      standard_class_name = Utils.instance.get_styled_class_name(cls.model.name)
      routeName = Utils.instance.get_styled_file_name(cls.get_u_name)

      bld.render_component_declaration(ComponentConfig.new
        .w_selector_name(filePart)
        .w_file_part(filePart)
        .w_imports(["CommonModule, RouterModule"]))

      bld.separate

      bld.start_block("export class " + get_class_name(cls) + " implements OnInit ")

      bld.add("public pageObv: Observable<FilteredPageRespTpl<" + standard_class_name + ">> = new Observable<FilteredPageRespTpl<" + standard_class_name + ">>;")
      bld.add("public page: FilteredPageRespTpl<" + standard_class_name + "> = new FilteredPageRespTpl<" + standard_class_name + ">;")
      bld.add("public pageReq: FilteredPageReqTpl<" + standard_class_name + "> = new FilteredPageReqTpl<" + standard_class_name + ">;")

      bld.separate

      if cls.model.data_filter.has_search_filter?
        if cls.model.data_filter.has_shared_filter?
          subjectVar = Utils.instance.get_search_subject(cls.model.data_filter.search_filter)
          bld.add "public " + Utils.instance.get_styled_variable_name(subjectVar) + ": Subject<string> = new Subject<string>();"
        else
          for col in cls.model.data_filter.search_filter.columns
            subjectVar = Utils.instance.get_search_subject_var(col)
            bld.add "public " + Utils.instance.get_styled_variable_name(subjectVar) + ": Subject<string> = new Subject<string>();"
          end
        end
      end

      bld.separate

      inst_fun = CodeStructure::CodeElemFunction.new(cls)

      constructorParams = inst_fun.parameters.vars

      userServiceVar = Utils.instance.create_var_for(cls, "class_angular_data_store_service", "private")
      inst_fun.add_param(userServiceVar)
      inst_fun.add_param_from("route", "ActivatedRoute", "private")

      bld.start_function("constructor", inst_fun)

      if cls.model.data_filter.has_search_filter?
        if cls.model.data_filter.has_shared_filter?
          subjectVar = Utils.instance.get_search_subject(cls.model.data_filter.search_filter)
          bld.add "this." + Utils.instance.get_styled_variable_name(subjectVar) + ".pipe("
          bld.iadd "debounceTime(250),"
          bld.iadd "distinctUntilChanged())"
          bld.add ".subscribe((p) =>  { this.goToPage(0); });"
        else
          for col in cls.model.data_filter.search_filter.columns
            subjectVar = Utils.instance.get_search_subject_var(col)
            bld.add "this." + Utils.instance.get_styled_variable_name(subjectVar) + ".pipe("
            bld.iadd "debounceTime(250),"
            bld.iadd "distinctUntilChanged())"
            bld.add ".subscribe((p) =>  { this.goToPage(0); });"

            bld.separate
          end
        end
      end

      bld.end_block

      bld.separate

      bld.start_block("ngOnInit()")
      bld.add "this.updatePageData();"
      bld.end_block

      bld.separate

      bld.start_block("getVisiblePageCount()")
      bld.add("return Math.min((this.page?.pageCount ?? 0, 10));")
      bld.end_block

      bld.separate

      bld.start_block("updatePageData()")
      bld.add("this.pageObv = " + "this." + Utils.instance.get_styled_variable_name(userServiceVar) + ".listing(this.pageReq);")
      bld.start_block "this.pageObv.subscribe((p) =>  "
      bld.add "this.page = p;"
      bld.add "this.pageReq.pageNum = this.page.pageNum;"
      bld.add "this.pageReq.pageSize = this.page.pageSize;"
      bld.end_block ");"
      bld.end_block

      bld.start_block("goToPage(pageNum: number)")
      bld.add("this.pageReq.pageNum = pageNum;")
      bld.add "this.updatePageData();"
      bld.end_block

      bld.start_block("goToPreviousPage()")
      bld.add "if (this.pageReq.pageNum > 0)"
      bld.iadd "this.goToPage(this.pageReq.pageNum - 1);"
      bld.end_block

      bld.start_block("goToNextPage()")
      bld.add "if (this.pageReq.pageNum < this.page.pageCount - 1)"
      bld.iadd "this.goToPage(this.pageReq.pageNum + 1);"
      bld.end_block

      bld.start_block "sortBy(colName: string)"
      bld.start_block "if (colName === this.pageReq.sortBy)"
      bld.add "this.pageReq.sortAsc = !this.pageReq.sortAsc;"
      bld.mid_block "else"
      bld.add "this.pageReq.sortBy = colName;"
      bld.add "this.pageReq.sortAsc = true;"
      bld.end_block
      bld.add "this.updatePageData();"
      bld.end_block

      if cls.model.data_filter.has_search_filter?
        if cls.model.data_filter.has_shared_filter?
          bld.start_block("onSearch(event: any)")
          bld.add "this.pageReq.searchParams.set('" + Utils.instance.style_as_variable(cls.model.data_filter.search_filter.get_name) + "', event.target.value);"
          subjectVar = Utils.instance.get_search_subject(cls.model.data_filter.search_filter)
          bld.add "this." + Utils.instance.get_styled_variable_name(subjectVar) + ".next(event.target.value);"
          bld.end_block
        else
          for col in cls.model.data_filter.search_filter.columns
            bld.start_block(Utils.instance.style_as_function("on search " + col) + "(event: any)")
            bld.add "this.pageReq.searchParams.set('" + Utils.instance.style_as_variable(col) + "', event.target.value);"
            subjectVar = Utils.instance.get_search_subject_var(col)
            bld.add "this." + Utils.instance.get_styled_variable_name(subjectVar) + ".next(event.target.value);"
            bld.end_block
          end
        end
      end

      bld.separate

      for act in cls.actions
        if !act.trigger.nil?
          triggerFun = Utils.instance.get_styled_function_name("on " + act.trigger)
          if act.trigger == "delete"
            bld.start_block(triggerFun + "(item: " + standard_class_name + ")")
            bld.add "this." + Utils.instance.get_styled_variable_name(userServiceVar) + "." + act.trigger + "(item)"
            bld.end_block
          else
            bld.start_block(triggerFun + "(item: " + standard_class_name + ")")
            bld.end_block
          end
        end
      end

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularListing.new)
