##
# Class:: Interface
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/source_renderer_csharp'

require 'code_elem_parent'
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
    #   bld.lfName = Utils.instance.get_styled_file_name(cls.get_u_name)
    #   bld.lfExtension = Utils.instance.get_extension('body')
    #   render_body_content(cls, bld)

    #   srcFiles << bld

    #   srcFiles
    # end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      # Add in any dependencies required by functions
      for fun in cls.functions
        if fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION && fun.isTemplate
          templ = XCTEPlugin.findMethodPlugin('csharp', fun.name)
          if !templ.nil?
            templ.process_dependencies(cls, bld, fun)
          else
            puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end
        end
      end

#     Utils.instance.genUses(cls.uses, bld)

      # Process namespace items
      bld.start_block('namespace ' << cls.namespace.get('.')) if cls.namespace.hasItems?

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

      # Process namespace items
      return unless cls.namespace.hasItems?

      bld.end_block(' // namespace ' + cls.namespace.get('.'))
      bld.add
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassInterface.new)
