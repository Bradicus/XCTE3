##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "class_standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/class_base'

require 'code_structure/code_elem_parent'
require 'lang_file'

module XCTETypescript
  class EnumStandard < ClassBase
    def initialize
      super

      @name = 'enum'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    def genHeaderComment(cls, bld)
      bld.add('/**')
      bld.add('* @enum ' + cls.get_u_name)

      bld.add('* @author ' + cfg.codeAuthor) if !cfg.codeAuthor.nil?



      if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0
        bld.add('*')
        bld.add('* ' + cfg.codeLicense)
      end

      bld.add('* ')

      if !cls.model.description.nil?
        cls.model.description.each_line do |descLine|
          bld.add('* ' << descLine.strip) if descLine.strip.size > 0
        end
      end

      bld.add('*/')
    end

    def render_body_content(cls, bld)

      classDec = 'export enum ' + get_class_name(cls)

      bld.start_block(classDec)

      # Generate class variables
      enum_list = []

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|   
          enumDec =  Utils.instance.get_styled_enum_name(var.name)    
          if var.defaultValue != nil
            enumDec += " = " + var.defaultValue
          end  
          enum_list.push Utils.instance.get_styled_enum_name(var.name)
      }))

      bld.add enum_list.join(",\n" + bld.indentChars)

      bld.end_block
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::EnumStandard.new)
