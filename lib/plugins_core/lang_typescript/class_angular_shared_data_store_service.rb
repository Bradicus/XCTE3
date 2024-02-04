##
# Class:: ClassAngularSharedDataStoreService
#
module XCTETypescript
  class ClassAngularSharedDataStoreService < ClassBase
    def initialize
      @name = 'class_angular_shared_data_store_service'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + ' shared data store service'
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

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

      itemVar = Utils.instance.create_var_for(cls, 'standard')

      if cls.data_node['isList'] == 'true'
        observableType = 'Observable<' + Utils.instance.get_styled_class_name(cls.model.name) + '[]>'
        bld.add('item: ' + observableType + ' = new ' + observableType + ';')
      else
        observableType = 'Observable<' + Utils.instance.get_styled_class_name(cls.model.name) + '>'
        bld.add('item: ' + observableType + ' = new ' + observableType + ';')
      end

      bld.add('lastUpdate: Date = new Date(0);')
      bld.add('expireMinutes: Number = 5;')

      dataServiceVar = Utils.instance.create_var_for(cls, 'class_angular_data_store_service')

      constructorParams = []
      Utils.instance.addParamIfAvailable(constructorParams, dataServiceVar)

      bld.separate
      bld.start_function_paramed('constructor', constructorParams)
      bld.endFunction

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularSharedDataStoreService.new)
