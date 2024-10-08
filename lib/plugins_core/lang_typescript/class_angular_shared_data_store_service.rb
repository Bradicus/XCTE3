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

    def get_unformatted_class_name(cls)
      cls.get_u_name + " shared data store service"
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.style_as_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension("body")

      process_dependencies(cls)
      render_dependencies(cls, bld)

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

      itemVar = Utils.instance.create_var_for(cls, "class_standard")
      itemClassName = Utils.instance.style_as_class(cls.model.name)

      if cls.data_node["isList"] == "true"
        bld.add("item = signal<" + itemClassName + ">([])>;")
      else
        bld.add("item = signal<" + itemClassName + ">(new " + itemClassName + ");")
      end

      bld.add("lastUpdate: Date = new Date(0);")
      bld.add("expireMinutes: Number = 5;")

      dataServiceVar = Utils.instance.create_var_for(cls, "class_angular_data_store_service")

      inst_fun = CodeStructure::CodeElemFunction.new(cls)
      inst_fun.name = "constructor"
      inst_fun.add_param(dataServiceVar)

      bld.separate
      start_function_elem(bld, inst_fun)
      bld.endFunction

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularSharedDataStoreService.new)
