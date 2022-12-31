##
# Class:: Standard
# Author:: Brad Ottoson
#

require "plugins_core/lang_java/utils.rb"
require "plugins_core/lang_java/class_base.rb"
require "plugins_core/lang_java/source_renderer_java.rb"
require "code_elem.rb"
require "code_elem_use.rb"
require "code_elem_namespace.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTEJava
  class ClassWebApiController < ClassBase
    def initialize
      @name = "web_api_controller"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName + " controller"
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

    def genFileComment(cls, bld)
      bld.add("/**")
      bld.add("* Web API controller")
      bld.add("*/")
    end

    def process_dependencies(cls, bld)
      Utils.instance.requires_class_type(cls, "class_jpa_entity")
      cls.addUse("org.springframework.web.bind.annotation.*")
      cls.addUse("org.springframework.beans.factory.annotation.Autowired")
      super
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)

      # Add in any dependencies required by functions
      Utils.instance.eachFun(UtilsEachFunParams.new(cls, bld, lambda { |fun|
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("java", fun.name)
          if templ != nil
            templ.process_dependencies(cls, bld, fun)
          else
            puts "ERROR no plugin for function: " + fun.name + "   language: java"
          end
        end
      }))

      classDec = cls.model.visibility + " class " + getClassName(cls)

      for par in (0..cls.baseClasses.size)
        if cls.baseClasses[par] != nil
          classDec << ", " << cls.baseClasses[par].visibility << " " << cls.baseClasses[par].name
        end
      end

      bld.add("@RestController")
      bld.startClass(classDec)

      for inj in cls.injections
        bld.add("@Autowired")
        bld.add(Utils.instance.getVarDec(inj))
      end

      # Generate code for functions
      render_functions(cls, bld)

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTEJava::ClassWebApiController.new)
