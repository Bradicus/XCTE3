##
# Class:: Standard
# Author:: Brad Ottoson
#

require 'plugins_core/lang_java/utils'
require 'plugins_core/lang_java/class_base'
require 'plugins_core/lang_java/source_renderer_java'

require 'code_elem_use'
require 'code_elem_namespace'
require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTEJava
  class ClassWebApiController < ClassBase
    def initialize
      @name = 'web_api_controller'
      @language = 'java'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' controller'
    end

    def render_file_comment(_cls, bld)
      bld.add('/**')
      bld.add('* Web API controller')
      bld.add('*/')
    end

    def process_dependencies(cls, bld)
      Utils.instance.requires_class_type(cls, cls, 'standard')
      cls.addUse('org.springframework.web.bind.annotation.*')
      cls.addUse('org.springframework.beans.factory.annotation.Autowired')

      cls.addUse('org.springframework.http.HttpStatus')
      cls.addUse('org.springframework.http.MediaType')
      cls.addUse('org.springframework.http.ResponseEntity')
      cls.addUse('org.mapstruct.factory.Mappers')

      super
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      # Add in any dependencies required by functions
      Utils.instance.each_fun(UtilsEachFunParams.new(cls, bld, lambda { |fun|
        if fun.isTemplate
          templ = XCTEPlugin.findMethodPlugin('java', fun.name)
          if !templ.nil?
            templ.process_dependencies(cls, bld, fun)
          else
            puts 'ERROR no plugin for function: ' + fun.name + '   language: java'
          end
        end
      }))

      classDec = cls.model.visibility + ' class ' + get_class_name(cls)

      for par in (0..cls.baseClasses.size)
        if !cls.baseClasses[par].nil?
          classDec << ', ' << cls.baseClasses[par].visibility << ' ' << cls.baseClasses[par].name
        end
      end

      bld.add('@RestController')
      bld.start_class(classDec)

      if cls.model.data_filter.paging.page_sizes.length > 0
        bld.add('final List<Integer> pageSizes = List.of(' + cls.model.data_filter.paging.page_sizes.join(',') + ');')
        bld.separate
      end

      if !cls.model.data_filter.search.columns.empty?
        bld.add('final List<String> searchCols = List.of("' + cls.model.data_filter.search.columns.join('","') + '");')
        bld.separate
      end

      for inj in cls.injections
        bld.add('@Autowired')
        bld.add(Utils.instance.get_var_dec(inj))
      end

      mapperName = 'mapper'

      if !cls.dataClass.nil?
        mapperClassName = Utils.instance.get_styled_class_name(cls.dataClass.model_name + ' mapper')
        bld.separate
        bld.add(mapperClassName + ' ' + mapperName + ' = Mappers.getMapper( ' + mapperClassName + '.class );')
        bld.separate
      end

      # Generate code for functions
      render_functions(cls, bld)

      # @Query("SELECT u FROM User u WHERE (:name is null or u.name = :name) and (:lastname is null"
      #  null + " or u.lastname= :lastname)")
      # Page<User> search(@Param("name") String name, @Param("lastname") String lastname, Pageable pageable);

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTEJava::ClassWebApiController.new)
