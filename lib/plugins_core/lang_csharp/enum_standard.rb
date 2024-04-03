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

require 'code_structure/code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class EnumStandard < XCTEClassBase
    def initialize
      super

      @name = 'enum'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    def genHeaderComment(cls, hFile)
      hFile.add('/**')
      hFile.add('* @enum ' + cls.get_u_name)

      hFile.add('* @author ' + cfg.codeAuthor) if !cfg.codeAuthor.nil?

      hFile.add('* ' + cfg.codeCompany) if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0

      if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0
        hFile.add('*')
        hFile.add('* ' + cfg.codeLicense)
      end

      hFile.add('* ')

      if !cls.model.description.nil?
        cls.model.description.each_line do |descLine|
          hFile.add('* ' << descLine.strip) if descLine.strip.size > 0
        end
      end

      hFile.add('*/')
    end

    def getBody(cls, hFile)

      classDec = cls.model.visibility + ' enum  ' + get_class_name(cls)

      hFile.start_block(classDec)

      # Generate class variables
      varArray = []

      for vGrp in cls.model.groups
        cls.model.getAllVarsFor(varArray)
      end

      for i in 0..(varArray.length - 1)
        var = varArray[i]
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          hFile.add(Utils.instance.get_styled_enum_name(var.name))
          hFile.same_line(' = ' + var.defaultValue) if !var.defaultValue.nil?
          hFile.same_line(',') if i != varArray.length - 1
        elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
          hFile.add(Utils.instance.get_comment(var))
        elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
          hFile.add(var.formatText)
        end
      end

      hFile.end_block(';')

      # Process namespace items
      if cls.namespace.hasItems?
        cls.namespace.ns_list.reverse_each do |nsItem|
          hFile.end_block('  // namespace ' << nsItem)
        end
        hFile.add
      end

      hFile.add('#endif')
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::EnumStandard.new)
