require "plugins_core/lang_java/utils"
require "x_c_t_e_class_base"

# This class contains functions that may be usefull in any type of class
module XCTEJava
  class ClassBase < XCTEClassBase
    def dutils
      Utils.instance
    end

    def get_source_renderer
      return SourceRendererJava.new
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

      render_namespace_start(cls, bld)
      render_dependencies(cls, bld)

      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      render_namespace_end(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def render_namespace_start(cls, bld)
      # Process namespace items
      return unless cls.namespace.hasItems?

      bld.add("package " + dutils().style_as_namespace((cls.namespace.get(".") + ";")))
      bld.separate
    end

    def render_namespace_end(cls, bld)
    end

    def process_dependencies(cls, bld)
      # Generate dependency code for functions
      for fun in cls.functions
        process_fuction_dependencies(cls, bld, fun)
      end

      cls.addUse("java.time.LocalDateTime") if cls.model.hasVariableType("datetime")

      cls.addUse("import java.util.List") if hasList(cls)

      return if cls.data_class.nil?

      Utils.instance.requires_class_ref(cls, cls.data_class)
      #  Utils.instance.requires_class_type(cls, cls.dataClass, "class_standard")

      super
    end

    def process_fuction_dependencies(cls, bld, fun)
      return unless fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION

      templ = XCTEPlugin.findMethodPlugin(dutils.langProfile.name, fun.name)
      if !templ.nil?
        templ.process_dependencies(cls, bld, fun)
      else
        # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
      end
    end

    def render_dependencies(cls, bld)
      bld.seperate_if(cls.uses.length > 0)

      for use in cls.uses
        bld.add("import " + use.namespace.get(".") + ";")

        # if inc.itype == "<"
        #   bld.add("#include <" << incPathAndName << ">")
        # elsif inc.name.count(".") > 0
        #   bld.add('#include "' << incPathAndName << '"')
        # else
        #   bld.add('#include "' << incPathAndName << "." << Utils.instance.get_extension("header") << '"')
        # end
      end

      bld.seperate_if(cls.uses.length > 0)
    end

    def render_header_var_group_getter_setters(cls, bld)
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.genGet
          templ = XCTEPlugin.findMethodPlugin("java", "method_get")
          templ.render_function(var, bld) if !templ.nil?
        end
        if var.genSet
          templ = XCTEPlugin.findMethodPlugin("java", "method_set")
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
