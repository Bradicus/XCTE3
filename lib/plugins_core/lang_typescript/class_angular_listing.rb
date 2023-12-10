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
      cls.addInclude("shared/dto/model/" + Utils.instance.getStyledFileName(cls.model.name), Utils.instance.getStyledClassName(cls.model.name))

      cls.addInclude("shared/paging/filtered-page-req-tpl", "FilteredPageReqTpl")
      cls.addInclude("shared/paging/filtered-page-resp-tpl", "FilteredPageRespTpl")
      
      if cls.model.paging.search.columns != nil  
        cls.addInclude("rxjs", "Subject, debounceTime, distinctUntilChanged", "lib")
      end

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

      bld.add("public pageObv: Observable<FilteredPageRespTpl<" + standardClassName + ">> = new Observable<FilteredPageRespTpl<" + standardClassName + ">>;")
      bld.add("public page: FilteredPageRespTpl<" + standardClassName + "> = new FilteredPageRespTpl<" + standardClassName + ">;")
      bld.add("public pageReq: FilteredPageReqTpl<" + standardClassName + "> = new FilteredPageReqTpl<" + standardClassName + ">;")

      bld.separate

      if cls.model.paging.search.columns.length > 0
        subjectVar = Utils.instance.get_search_subject(cls.model.paging.search)
        bld.add 'public ' + subjectVar.name + ': Subject<string> = new Subject<string>();'
        bld.separate
      end

      bld.separate

      constructorParams = Array.new
      userServiceVar = Utils.instance.createVarFor(cls, "class_angular_data_store_service")
      Utils.instance.addParamIfAvailable(constructorParams, userServiceVar)
      constructorParams.push("private route: ActivatedRoute")
      bld.startFunctionParamed("constructor", constructorParams)

      if cls.model.paging.search.columns.length > 0
        subjectVar = Utils.instance.get_search_subject(cls.model.paging.search)
        bld.add 'this.' + subjectVar.name + '.pipe('
        bld.iadd 'debounceTime(250),'
        bld.iadd 'distinctUntilChanged())'
        bld.add '.subscribe((p) =>  { this.goToPage(0); });'        
        bld.separate
      end

      bld.endBlock

      bld.separate

      searchNames = load_search_names(cls)

      bld.startBlock("ngOnInit()")
      bld.add "this.updatePageData();"
      bld.endBlock

      bld.separate

      bld.startBlock("getVisiblePageCount()")
      bld.add("return Math.min((this.page?.pageCount ?? 0, 10));")
      bld.endBlock

      bld.separate

      bld.startBlock("updatePageData()")
      bld.add("this.pageObv = " + "this." + Utils.instance.getStyledVariableName(userServiceVar) + ".listing(this.pageReq);")
      bld.startBlock "this.pageObv.subscribe((p) =>  "
      bld.add "this.page = p;"
      bld.add "this.pageReq.pageNum = this.page.pageNum;"
      bld.add "this.pageReq.pageSize = this.page.pageSize;"
      bld.endBlock ");"
      bld.endBlock

      bld.separate

      bld.startBlock("goToPage(pageNum: number)")
      bld.add("this.pageReq.pageNum = pageNum;")
      bld.add "this.updatePageData();"
      bld.endBlock

      bld.separate

      bld.startBlock("goToPreviousPage()")
      bld.add "if (this.pageReq.pageNum > 0)"
      bld.iadd "this.goToPage(this.pageReq.pageNum - 1);"
      bld.endBlock

      bld.separate

      bld.startBlock("goToNextPage()")
      bld.add "if (this.pageReq.pageNum < this.page.pageCount - 1)"
      bld.iadd "this.goToPage(this.pageReq.pageNum + 1);"
      bld.endBlock

      bld.startBlock "sortBy(colName: string)"
      bld.startBlock "if (colName === this.pageReq.sortBy)"      
      bld.add "this.pageReq.sortAsc = !this.pageReq.sortAsc;"
      bld.midBlock 'else'
      bld.add "this.pageReq.sortBy = colName;"
      bld.add "this.pageReq.sortAsc = true;"
      bld.endBlock
      bld.add "this.updatePageData();"
      bld.endBlock
      
      bld.startBlock("onSearch(event: any)")
      bld.add "this.pageReq.searchValue = event.target.value;"
      
      if cls.model.paging.search.columns.length > 0
        subjectVar = Utils.instance.get_search_subject(cls.model.paging.search)
        bld.add 'this.' + subjectVar.name + '.next(event.target.value);'
      end

      bld.endBlock

      bld.separate

      for act in cls.actions
        if act.trigger != nil
          triggerFun = Utils.instance.getStyledFunctionName("on " + act.trigger)
          if act.trigger == 'delete'
            bld.startBlock(triggerFun + "(item: " + standardClassName + ")")
            bld.add "this." + Utils.instance.getStyledVariableName(userServiceVar) + "." + act.trigger + "(item)"
            bld.endBlock
          else
            bld.startBlock(triggerFun + "(item: " + standardClassName + ")")
            bld.endBlock
          end
        end
      end

      # Generate code for functions
      render_functions(cls, bld)

      bld.endClass
    end

    def load_search_names(cls)
      names = Array.new

      cls.xmlElement.elements.each("search_by") { |xmlNode|
        names.push(xmlNode.attributes["name"])
      }

      return names
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularListing.new)
