##
# Class:: Standard
# Author:: Brad Ottoson
#

require "plugins_core/lang_java/utils"
require "plugins_core/lang_java/class_base"
require "plugins_core/lang_java/source_renderer_java"

require "code_structure/code_elem_use"
require "code_structure/code_elem_namespace"
require "code_structure/code_elem_parent"
require "lang_file"
require "x_c_t_e_plugin"

module XCTEJava
  class ClassWebApiController < ClassBase
    def initialize
      @name = "web_api_controller"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + " controller"
    end

    def render_file_comment(_cls, bld)
      bld.add("/**")
      bld.add("* Web API controller")
      bld.add("*/")
    end

    def process_dependencies(cls)
      Utils.instance.requires_class_type(cls, cls, "class_standard")
      cls.addUse("org.springframework.web.bind.annotation.*")
      cls.addUse("org.springframework.beans.factory.annotation.Autowired")

      cls.addUse("org.springframework.http.HttpStatus")
      cls.addUse("org.springframework.http.MediaType")
      cls.addUse("org.springframework.http.ResponseEntity")
      cls.addUse("org.mapstruct.factory.Mappers")

      super
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      # Add in any dependencies required by functions
      Utils.instance.each_fun(UtilsEachFunParams.new.w_cls(cls).w_bld(bld).w_fun_cb(lambda { |fun|
        if fun.isTemplate
          templ = PluginManager.find_method_plugin("java", fun.name)
          if !templ.nil?
            templ.process_dependencies(cls, fun)
          else
            puts "ERROR no plugin for function: " + fun.name + "   language: java"
          end
        end
      }))

      classDec = cls.model.visibility + " class " + get_class_name(cls)

      for par in (0..cls.base_classes.size)
        if !cls.base_classes[par].nil?
          classDec << ", " << cls.base_classes[par].visibility << " " << cls.base_classes[par].name
        end
      end

      bld.add("@RestController")
      bld.start_class(classDec)

      if cls.model.data_filter.paging.page_sizes.length > 0
        bld.add("final List<Integer> pageSizes = List.of(" + cls.model.data_filter.paging.page_sizes.join(",") + ");")
        bld.separate
      end

      search_columns = cls.model.data_filter.get_search_cols

      if search_columns.length > 0
        bld.add('final List<String> searchCols = List.of("' + search_columns.join('","') + '");')
      end

      bld.separate

      for inj in cls.injections
        bld.add("@Autowired")
        bld.add(Utils.instance.get_var_dec(inj))
      end

      mapperName = "mapper"

      if !cls.data_class.nil?
        mapperClassName = Utils.instance.style_as_class(cls.data_class.model_name + " mapper")
        bld.separate
        bld.add(mapperClassName + " " + mapperName + " = Mappers.getMapper( " + mapperClassName + ".class );")
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
