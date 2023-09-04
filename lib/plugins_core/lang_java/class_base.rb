require "plugins_core/lang_java/utils.rb"
require "x_c_t_e_class_base.rb"

# This class contains functions that may be usefull in any type of class
module XCTEJava
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererJava.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      process_dependencies(cls, bld)

      render_package_start(cls, bld)
      render_dependencies(cls, bld)

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      # Generate dependency code for functions
      for fun in cls.functions
        process_fuction_dependencies(cls, bld, fun)
      end

      if (cls.model.hasVariableType("datetime"))
        cls.addUse("java.time.LocalDateTime")
      end

      if hasList(cls)
        cls.addUse("import java.util.List")
      end

      if (cls.dataClass != nil)
        Utils.instance.requires_class_ref(cls, cls.dataClass)
        #  Utils.instance.requires_class_type(cls, cls.dataClass, "standard")
      end
    end

    def process_fuction_dependencies(cls, bld, fun)
      if fun.elementId == CodeElem::ELEM_FUNCTION
        templ = XCTEPlugin::findMethodPlugin(get_default_utils().langProfile.name, fun.name)
        if templ != nil
          templ.process_dependencies(cls, bld, fun)
        else
          #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    end

    def render_dependencies(cls, bld)
      bld.separateIf(cls.uses.length > 0)

      for use in cls.uses
        bld.add("import " + use.namespace.get(".") + ";")

        # if inc.itype == "<"
        #   bld.add("#include <" << incPathAndName << ">")
        # elsif inc.name.count(".") > 0
        #   bld.add('#include "' << incPathAndName << '"')
        # else
        #   bld.add('#include "' << incPathAndName << "." << Utils.instance.getExtension("header") << '"')
        # end
      end

      bld.separateIf(cls.uses.length > 0)
    end

    def render_package_start(cls, bld)
      # Process namespace items
      if cls.namespace.hasItems?()
        bld.add("package " + cls.namespace.get(".") + ";")
        bld.separate
      end
    end

    def render_header_var_group_getter_setters(cls, bld)
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if (var.genGet)
          templ = XCTEPlugin::findMethodPlugin("java", "method_get")
          if templ != nil
            templ.get_definition(var, bld)
          end
        end
        if (var.genSet)
          templ = XCTEPlugin::findMethodPlugin("java", "method_set")
          if templ != nil
            templ.get_definition(var, bld)
          end
        end
      }))
    end

    def genFileComment(cls, bld)
      cfg = UserSettings.instance
      headerString = String.new

      bld.add("/**")
      bld.add("* @class " + getClassName(cls))

      if (cfg.codeAuthor != nil)
        bld.add("* @author " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        bld.add("* " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.strip.size > 0
        bld.add("*\n* " + cfg.codeLicense)
      end

      bld.add("* ")

      if (cls.description != nil)
        cls.description.each_line { |descLine|
          if descLine.strip.size > 0
            bld.add("* " << descLine.chomp)
          end
        }
      end

      bld.add("*/")

      return(headerString)
    end
  end
end
