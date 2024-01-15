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

require 'plugins_core/lang_java/utils'
require 'plugins_core/lang_java/x_c_t_e_java'
require 'plugins_core/lang_java/class_base'
require 'code_elem'
require 'code_elem_parent'
require 'code_elem_model'
require 'lang_file'

module XCTEJava
  class ClassDataSet < ClassBase
    def initialize
      @name = 'class_data_set'
      @language = 'java'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def process_dependencies(cls, bld)
      # Generate class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        Utils.instance.requires_var(cls, var) if !is_primitive(var)
      }))

      # if hasList(cls)
      cls.addUse('java.util.*')
      # end

      cls.addUse('org.springframework.data.domain.Page')

      super
    end

    def gen_file_comment(cls, bld)
      cfg = UserSettings.instance

      bld.add('/**')
      bld.add('* @class ' + cls.name)

      bld.add('* @author ' + cfg.codeAuthor) if !cfg.codeAuthor.nil?

      bld.add('* ' + cfg.codeCompany) if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0

      bld.add("*\n* " + cfg.codeLicense) if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0

      bld.add('*')

      if !cls.description.nil?
        cls.description.each_line do |descLine|
          bld.add('* ' << descLine.chomp) if descLine.strip.size > 0
        end
      end

      bld.add('*/')
    end

    # Returns the code for the header for this class
    def gen_body_content(cls, bld)
      cfg = UserSettings.instance

      bld.start_class('public class ' << cls.name)

      bld.separate if Utils.instance.has_an_array?(cls)

      # Generate class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.getVarDec(var))
      }))

      bld.separate

      render_functions(cls, bld)
      render_header_var_group_getter_setters(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTEJava::ClassDataSet.new)
