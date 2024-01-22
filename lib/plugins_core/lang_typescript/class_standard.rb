##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require 'plugins_core/lang_typescript/utils'
require 'plugins_core/lang_typescript/x_c_t_e_typescript'
require 'code_elem'
require 'code_elem_parent'
require 'code_elem_model'
require 'lang_file'

module XCTETypescript
  class ClassStandard < ClassBase
    def initialize
      @name = 'standard'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def process_dependencies(cls, bld)
      super

      # Generate class variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        Utils.instance.try_add_include_for_var(cls, var, 'standard') if !Utils.instance.is_primitive(var)
      }))
    end

    def gen_file_comment(cls, bld)
      cfg = UserSettings.instance
      headerString = String.new

      bld.add('/**')
      bld.add('* @class ' + cls.name)

      bld.add('* @author ' + cfg.codeAuthor) if !cfg.codeAuthor.nil?

      bld.add('* ' + cfg.codeCompany) if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0

      bld.add("*\n* " + cfg.codeLicense) if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0

      bld.add('* ')

      if !cls.description.nil?
        cls.description.each_line do |descLine|
          bld.add('* ' << descLine.chomp) if descLine.strip.size > 0
        end
      end

      bld.add('*/')

      headerString
    end

    # Returns the code for the header for this class
    def gen_body_content(cls, bld)
      headerString = String.new

      bld.separate

      render_class_start(cls, bld)

      # Generate class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.getVarDec(var))
      }))

      bld.separate
      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassStandard.new)
