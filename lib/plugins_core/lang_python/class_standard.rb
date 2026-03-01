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

require 'plugins_core/lang_python/utils'
require 'plugins_core/lang_python/x_c_t_e_python'

require 'code_structure/code_elem_parent'
require 'code_structure/code_elem_model'
require 'lang_file'

module XCTEPython
  class ClassStandard < ClassBase
    def initialize
      @name = 'class_standard'
      @language = 'python'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      return cls.get_u_name
    end

    def gen_source_files(cls)
      srcFiles = []

      rend = SourceRendererPython.new
      rend.lfName = Utils.instance.style_as_file_name(cls.get_u_name)
      rend.lfExtension = Utils.instance.get_extension('body')
      genPythonFileComment(cls, rend)
      render_body_content(cls, rend)

      srcFiles << rend

      return srcFiles
    end

    def genPythonFileComment(cls, rend)
      cfg = UserSettings.instance

      rend.add('##')
      rend.add('# Class:: ' + Utils.instance.style_as_file_name(cls.get_u_name))

      if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0
        rend.add('# ' + cfg.codeCompany)
      end

      if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0
        rend.add("#\n# License:: " + cfg.codeLicense)
      end

      rend.add('# ')

      return if cls.model.description.nil?

      cls.model.description.each_line do |descLine|
        if descLine.strip.size > 0
          rend.add('# ' << descLine.chomp)
        end
      end
    end

    def render_body_content(cls, bld)
      inheritFrom = []

      # for b_cls_ref in cls.base_classes
      #   inheritFrom.push(dutils.get_class_ref_type(cls, b_cls_ref))
      # end

      # for icls in cls.interfaces
      #   inheritFrom.push(dutils.get_class_ref_type(cls, icls))
      # end

      classDec = 'class ' + get_class_name(cls)
      classDec += '(' + inheritFrom.join(', ') + ')' if !inheritFrom.empty?

      bld.start_class(classDec)

      # Process variables
      each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        Utils.instance.get_var_dec(var)
      }))

      bld.separate if cls.functions.length > 0

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end

    # Returns the code for the header for this class
    def genPythonFileContent(cls, rend)
      headerString = String.new

      rend.add

      for inc in cls.includes
        rend.add('import ' + inc.path + inc.name)
      end

      if !cls.includes.empty?
        rend.add
      end

      rend.start_class('class ' + Utils.instance.style_as_file_name(cls.get_u_name))

      for var in varArray
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && var.isStatic == true
          rend.add(Utils.instance.get_styled_variable_name(var))
        end
      end

      rend.add

      render_functions(cls, bld)

      rend.end_block('# class ' + Utils.instance.style_as_file_name(cls.get_u_name))
      rend.add
    end
  end
end

XCTEPlugin.registerPlugin(XCTEPython::ClassStandard.new)
