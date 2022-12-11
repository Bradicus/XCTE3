##
# Class:: ClassAngularService
#
module XCTETypescript
  class ClassAngularDatastoreService < ClassBase
    def initialize
      @name = "class_angular_data_store_service"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " data store service"
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      cls.addInclude("../../../environments/environment", "environment", "lib")
      cls.addInclude("@angular/core", "Injectable")
      cls.addInclude("@angular/common/http", "HttpClient ")
      cls.addInclude("rxjs", "Observable", "lib")

      fPath = Utils.instance.getStyledFileName(cls.model.name)
      cName = Utils.instance.getStyledClassName(cls.model.name)
      # Eventaully switch to finding standard class and using path from there
      cls.addInclude("shared/interfaces/" + fPath, cName)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.startBlock("@Injectable(")
      bld.add("providedIn: 'root',")
      bld.endBlock(")")
      bld.startClass("export class " + getClassName(cls))

      bld.add("private apiUrl='';")
      # bld.add("private dataExpires: Number = 600; // Seconds")
      # bld.add("private items: " + Utils.instance.getStyledClassName(cls.getUName()) + "[];")

      bld.separate
      bld.startFunction("constructor(private httpClient: HttpClient)")
      bld.add("this.apiUrl = environment.apiUrl;")
      bld.endFunction

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
        for group in vGroup.varGroups
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
            templ.get_definition(cls, bld)
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        else # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("typescript", "method_empty")
          if templ != nil
            templ.get_definition(fun, cfg)
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularDatastoreService.new)
