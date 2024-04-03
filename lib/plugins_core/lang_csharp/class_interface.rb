##
# Class:: Interface
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/source_renderer_csharp'

require 'code_structure/code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class ClassInterface < ClassBase
    def initialize
      @name = 'interface'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      if (cls.parent_elem.is_a?(CodeStructure::CodeElemClassSpec))
        parentPlug = XCTEPlugin.findClassPlugin(@language, cls.parent_elem.plug_name)
        return 'i ' + parentPlug.get_unformatted_class_name(cls.parent_elem)
      else
        return cls.get_u_name + ' engine'
      end
    end

    # def gen_source_files(cls)
    #   srcFiles = []

    #   cls.addUse('System.Data.SqlClient', 'SqlConnection')

    #   bld = SourceRendererCSharp.new
    #   bld.lfName = Utils.instance.style_as_file_name(cls.get_u_name)
    #   bld.lfExtension = Utils.instance.get_extension('body')
    #   render_body_content(cls, bld)

    #   srcFiles << bld

    #   srcFiles
    # end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)

#     Utils.instance.genUses(cls.uses, bld)

      classDec = cls.model.visibility + ' interface ' + get_class_name(cls)

      for par in (0..cls.base_classes.size)
        if par == 0 && !cls.base_classes[par].nil?
          classDec << ' : ' << cls.base_classes[par].visibility << ' ' << cls.base_classes[par].name
        elsif !cls.base_classes[par].nil?
          classDec << ', ' << cls.base_classes[par].visibility << ' ' << cls.base_classes[par].name
        end
      end

      bld.start_class(classDec)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassInterface.new)
