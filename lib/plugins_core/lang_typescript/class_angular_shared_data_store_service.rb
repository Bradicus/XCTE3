##
# Class:: ClassAngularSharedDataStoreService
#
module XCTETypescript
  class ClassAngularSharedDataStoreService < ClassBase
    def initialize
      @name = "class_angular_shared_data_store_service"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end
    
    def getUnformattedClassName(cls)
      return cls.getUName() + ' shared data store service'
    end
    
    def genSourceFiles(cls)
      srcFiles = Array.new
      
      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension('body')
      
      process_dependencies(cls, bld)
      render_dependencies(cls, bld)
      
      genFileComment(cls, bld)
      genFileContent(cls, bld)
      
      srcFiles << bld
      
      return srcFiles
    end
    
    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
      
    end
    
    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.startBlock("@Injectable(")
      bld.add("providedIn: 'root',")
      bld.endBlock(")")
      bld.startClass("export class " + getClassName(cls))
      
      bld.separate
      bld.startFunction("constructor(private httpClient: HttpClient)")
      bld.add("this.apiUrl = environment.apiUrl;")
      bld.endFunction
            
      # Generate code for functions
      render_functions(cls, bld)
      
      bld.endClass
    end
    
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularSharedDataStoreService.new)
