##
# Class:: Standard
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/class_base'
require 'plugins_core/lang_csharp/source_renderer_csharp'

require 'code_structure/code_elem_use'
require 'code_structure/code_elem_namespace'
require 'code_structure/code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class ClassWebApiController < ClassBase
    def initialize
      @name = 'web_api_controller'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + ' controller'
    end

    def process_dependencies(cls)
      cls.addUse('System.Data.SqlClient')
    end

    def render_file_comment(cls, bld)
      cfg = UserSettings.instance

      bld.add('/**')
      bld.add('* @author ' + cfg.codeAuthor) if !cfg.codeAuthor.nil?



      bld.add("*\n* " + cfg.codeLicense) if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0

      bld.add('*')

      if !cls.description.nil?
        cls.description.each_line do |descLine|
          bld.add('* ' << descLine.chomp) if descLine.strip.size > 0
        end
      end

      bld.add('*/')
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)

      classDec = cls.model.visibility + ' class ' + get_class_name(cls) + 'Controller'

      classDec << ' : ApiController'

      for par in (0..cls.base_classes.size)
        if !cls.base_classes[par].nil?
          classDec << ', ' << cls.base_classes[par].visibility << ' ' << cls.base_classes[par].name
        end
      end

      bld.start_class(classDec)
      bld.separate

      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassWebApiController.new)
