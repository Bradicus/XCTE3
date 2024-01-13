##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require 'plugins_core/lang_csharp/utils'
require 'code_elem'
require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class EnumStandard < XCTEPlugin
    def initialize
      @name = 'enum'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def gen_source_files(cls)
      srcFiles = []

      cls.setName(get_unformatted_class_name(cls))

      hFile = SourceRendererCpp.new
      hFile.lfName = Utils.instance.get_styled_file_name(cls.getUName)
      hFile.lfExtension = Utils.instance.get_extension('header')
      genHeaderComment(cls, hFile)
      getBody(cls, hFile)

      srcFiles << hFile

      srcFiles
    end

    def genHeaderComment(cls, hFile)
      hFile.add('/**')
      hFile.add('* @enum ' + cls.getUName)

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

    # Returns the code for the header for this class
    def getBody(cls, hFile)
      # Add in any dependencies required by functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION && fun.isTemplate
          templ = XCTEPlugin.findMethodPlugin('csharp', fun.name)
          if !templ.nil?
            templ.process_dependencies(cls, bld, fun)
          else
            puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end
        end
      end

      Utils.instance.genUses(cls.uses, bld)
      Utils.instance.genNamespaceStart(cls.namespace, bld)

      classDec = cls.model.visibility + ' enum  ' + getClassName(cls)

      hFile.start_block(classDec)

      # Generate class variables
      varArray = []

      for vGrp in cls.model.groups
        cls.model.getAllVarsFor(varArray)
      end

      for i in 0..(varArray.length - 1)
        var = varArray[i]
        if var.elementId == CodeElem::ELEM_VARIABLE
          hFile.add(Utils.instance.get_styled_enum_name(var.name))
          hFile.same_line(' = ' + var.defaultValue) if !var.defaultValue.nil?
          hFile.same_line(',') if i != varArray.length - 1
        elsif var.elementId == CodeElem::ELEM_COMMENT
          hFile.add(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          hFile.add(var.formatText)
        end
      end

      hFile.end_block(';')

      # Process namespace items
      if cls.namespace.hasItems?
        cls.namespace.nsList.reverse_each do |nsItem|
          hFile.end_block('  // namespace ' << nsItem)
        end
        hFile.add
      end

      hFile.add('#endif')
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::EnumStandard.new)
