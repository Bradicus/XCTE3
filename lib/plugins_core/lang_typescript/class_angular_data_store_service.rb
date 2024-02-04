##
# Class:: ClassAngularService
#
module XCTETypescript
  class ClassAngularDatastoreService < ClassBase
    def initialize
      @name = 'class_angular_data_store_service'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + ' data store service'
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')

      cls.addInclude('../../../environments/environment', 'environment', 'lib')
      cls.addInclude('@angular/core', 'Injectable')
      cls.addInclude('@angular/common/http', 'HttpClient, HttpParams')
      cls.addInclude('rxjs', 'Observable, map', 'lib')

      fPath = Utils.instance.get_styled_file_name(cls.model.name)
      cName = Utils.instance.get_styled_class_name(cls.model.name)
      # Eventaully switch to finding standard class and using path from there
      cls.addInclude('shared/dto/model/' + fPath, cName)

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
      bld.start_block('@Injectable(')
      bld.add("providedIn: 'root',")
      bld.end_block(')')
      bld.start_class('export class ' + get_class_name(cls))

      bld.add('private apiUrl=environment.apiUrl;')
      # bld.add("private dataExpires: Number = 600; // Seconds")
      # bld.add("private items: " + Utils.instance.get_styled_class_name(cls.get_u_name()) + "[];")

      bld.separate
      bld.start_function('constructor(private httpClient: HttpClient)')
      bld.add('this.apiUrl = environment.apiUrl;')
      bld.endFunction

      bld.separate

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      for var in vGroup.vars
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          bld.add(Utils.instance.get_var_dec(var))
        elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
          bld.same_line(Utils.instance.getComment(var))
        elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
          bld.add(var.formatText)
        end
        for group in vGroup.varGroups
          process_var_group(cls, bld, group)
        end
      end
    end

    def process_function(cls, bld, fun)
      bld.separate

      return unless fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION

      if fun.isTemplate
        templ = XCTEPlugin.findMethodPlugin('typescript', fun.name)
        if !templ.nil?
          templ.render_function(cls, bld)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      else # Must be empty function
        templ = XCTEPlugin.findMethodPlugin('typescript', 'method_empty')
        if !templ.nil?
          templ.render_function(fun, cfg)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularDatastoreService.new)
