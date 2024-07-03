##
# Class:: ClassTsqlDataStore
#
module XCTEJava
  class ClassTsqlDataStore < ClassBase
    def initialize
      super

      @name = 'tsql_data_store'
      @language = 'java'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + ' data store'
    end

    def process_dependencies(cls)
      Utils.instance.requires_class_type(cls, cls, 'class_db_entity')
      cls.addUse('org.springframework.data.jpa.repository.*')
      cls.addUse('org.springframework.data.domain.Page')
      cls.addUse('org.springframework.data.domain.PageRequest')

      super
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      id_var = cls.model.getFilteredVars(->(var) { var.name == 'id' })

      if id_var.nil?
        Log.error('Missing id var')
      end

      bld.start_class('public interface ' + get_class_name(cls) + ' extends JpaRepository<' +
                     Utils.instance.style_as_class(cls.model.name) + ', ' +
                     Utils.instance.getObjTypeName(id_var[0]) + '>')

      bld.separate
      # Generate class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(->(var) {}))

      bld.separate

      data_class = cls.model.findClassSpecByPluginName('class_db_entity')

      if !data_class.nil?
        related_classes = ClassModelManager.find_classes_with_data_model(data_class)

        for related_class in related_classes
          if related_class.model.data_filter.has_non_paging_filters?
            fun = Utils.instance.get_search_fun(data_class, related_class)

            if Utils.instance.needs_search_fun_declaration?(fun, related_class)
              bld.render_function_declairation(fun)
            end
          end
        end

        if related_class.nil?
          fun = Utils.instance.get_search_fun(cls, cls)

          if Utils.instance.needs_search_fun_declaration?(fun, cls)
            bld.render_function_declairation(fun)
          end
        end
      end

      bld.separate

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTEJava::ClassTsqlDataStore.new)
