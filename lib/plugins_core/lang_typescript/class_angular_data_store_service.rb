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

    def get_unformatted_class_name(cls)
      cls.get_u_name + " data store service"
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension("body")

      include_env_file(cls)

      cls.addInclude("@angular/core", "Injectable")
      cls.addInclude("@angular/common/http", "HttpClient, HttpParams")
      cls.addInclude("rxjs", "Observable, map", "lib")

      fPath = Utils.instance.get_styled_file_name(cls.model.name)
      cName = Utils.instance.get_styled_class_name(cls.model.name)
      # Eventaully switch to finding standard class and using path from there
      cls.addInclude("shared/dto/model/" + fPath, cName)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      bld.start_block("@Injectable(")
      bld.add("providedIn: 'root',")
      bld.end_block(")")
      bld.start_class("export class " + get_class_name(cls))

      bld.add("private apiUrl=environment.apiUrl;")
      # bld.add("private dataExpires: Number = 600; // Seconds")
      # bld.add("private items: " + Utils.instance.get_styled_class_name(cls.get_u_name()) + "[];")

      constructor = CodeStructure::CodeElemFunction.new(nil)
      cParam = CodeStructure::CodeElemVariable.new(nil)
      cParam.name = "httpClient"
      cParam.vtype = "HttpClient"
      cParam.visibility = "private"

      constructor.add_param(cParam)

      bld.separate
      bld.start_function("constructor", constructor)
      bld.add("this.apiUrl = environment.apiUrl;")
      bld.endFunction

      bld.separate

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularDatastoreService.new)
