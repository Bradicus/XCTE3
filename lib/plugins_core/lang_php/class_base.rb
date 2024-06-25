require "plugins_core/lang_php/utils"
require "x_c_t_e_class_base"

# This class contains functions that may be usefull in any type of class
module XCTEPhp
  class ClassBase < XCTEClassBase
    def dutils
      Utils.instance
    end

    def get_source_renderer
      return SourceRendererPhp.new
    end

    def get_sql_util(cls)
      if cls.model.findClassSpecByPluginName("tsql_data_store") != nil
        return XCTETSql::Utils.instance
      else
        return XCTESql::Utils.instance
      end
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = get_source_renderer()
      bld.lfName = dutils().style_as_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = dutils().get_extension("body")

      process_dependencies(cls, bld)

      bld.add("<?php")

      render_file_comment(cls, bld)
      render_namespace_start(cls, bld)
      render_dependencies(cls, bld)
      render_body_content(cls, bld)

      render_namespace_end(cls, bld)
      bld.add("?>")

      srcFiles << bld

      return srcFiles
    end

    def render_namespace_start(cls, bld)
      # Process namespace items
      return unless cls.namespace.hasItems?

      bld.add("package " + cls.namespace.get(".") + ";")
      bld.separate
    end

    def render_namespace_end(cls, bld)
    end

    def process_dependencies(cls, bld)
      super

      # Generate dependency code for functions
      for fun in cls.functions
        process_fuction_dependencies(cls, bld, fun)
      end

      return if cls.data_class.nil?

      Utils.instance.requires_class_ref(cls, cls.data_class)
      #  Utils.instance.requires_class_type(cls, cls.dataClass, "class_standard")
    end

    def process_fuction_dependencies(cls, bld, fun)
      return unless fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION

      templ = PluginManager.find_method_plugin(dutils.langProfile.name, fun.name)
      if !templ.nil?
        templ.process_dependencies(cls, bld, fun)
      else
        # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
      end
    end

    def render_dependencies(cls, bld)
      bld.seperate_if(cls.includes.length > 0)

      for inc in cls.includes
        outCode.add('include_once("' << inc.path << inc.name << '.php");')
      end

      bld.seperate_if(cls.includes.length > 0)
    end

    def render_header_var_group_getter_setters(cls, bld)
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.genGet
          templ = PluginManager.find_method_plugin("php", "method_get")
          templ.render_function(var, bld) if !templ.nil?
        end
        if var.genSet
          templ = PluginManager.find_method_plugin("php", "method_set")
          templ.render_function(var, bld) if !templ.nil?
        end
      }))
    end

    def render_file_comment(cls, bld)
      cfg = UserSettings.instance
      headerString = String.new

      bld.add("/**")
      bld.add("* @class " + get_class_name(cls))

      bld.add("* @author " + cfg.codeAuthor) if !cfg.codeAuthor.nil?

      bld.add("*\n* " + cfg.codeLicense) if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0

      bld.add("* ")

      if !cls.description.nil?
        cls.description.each_line do |descLine|
          bld.add("* " << descLine.chomp) if descLine.strip.size > 0
        end
      end

      bld.add("*/")

      headerString
    end
  end
end
