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

require 'plugins_core/lang_ruby/x_c_t_e_ruby'
require 'plugins_core/lang_ruby/utils'
require 'plugins_core/lang_ruby/class_base'
require 'x_c_t_e_plugin'
require 'code_elem'
require 'code_elem_parent'
require 'code_elem_model'
require 'lang_file'
require 'log'

module XCTERuby
  class ClassStandard < ClassBase
    def initialize
      super

      @name = 'standard'
      @language = 'ruby'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererRuby.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')
      gen_file_comment(cls, bld)
      gen_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def gen_file_comment(cls, bld)
      renderGlobalComment(cls.genCfg, bld)

      bld.separate

      bld.add('#')

      return if cls.description.nil?

      cls.description.each_line do |descLine|
        bld.add('# ' + descLine.chomp) if descLine.strip.size > 0
      end
    end

    # Returns the code for the header for this class
    def gen_body_content(cls, bld)
      bld.separate

      for inc in cls.includes
        bld.add("require '" << inc.path << inc.name << '.' << Utils.instance.get_extension('body'))
      end

      bld.separate

      render_namespace_starts(cls, bld)

      inheritFrom = ''

      inheritFrom = ' < ' + Utils.instance.getClassTypeName(cls.baseClasses[0]) if cls.baseClasses.length > 0

      if cls.baseClasses.length > 1
        Log.error("Ruby doesn't support multiple inheritance")
      end

      bld.start_class('class ' + get_class_name(cls) + inheritFrom)

      accessors = Accessors.new
      # Do automatic static array size declairations at top of class
      process_var_accessors(accessors, cls, bld, cls.model.varGroup)

      add_accessors('attr_accessor', accessors.both, bld)
      add_accessors('attr_attr_reader', accessors.readers, bld)
      add_accessors('attr_attr_writer', accessors.writers, bld)

      bld.separate

      bld.start_function 'def initialize'
      # Do automatic static array size declairations at top of class
      process_var_group(cls, bld, cls.model.varGroup)

      bld.endFunction

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.end_class
      render_namespace_ends(cls, bld)
    end

    # process variable group
    def process_var_accessors(accessors, cls, bld, vGroup)
      for var in vGroup.vars
        accessors.add(Accessor.new(var, var.genGet, var.genSet)) if var.genGet || var.genSet

        for group in vGroup.varGroups
          process_var_accessors(accessors, cls, bld, group)
        end
      end
    end

    def add_accessors(accName, accList, bld)
      return unless accList.length > 0

      bld.add(accName + ' :')
      bld.same_line(get_accessor_var_list(accList).join(', :'))
    end

    def get_accessor_var_list(accList)
      vList = []

      for acc in accList
        vList.push(Utils.instance.get_styled_variable_name(acc.var))
      end

      vList
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      for var in vGroup.vars
        case var.elementId
        when CodeElem::ELEM_VARIABLE
          bld.add(Utils.instance.getVarDec(var))
        when CodeElem::ELEM_COMMENT
          bld.same_line(Utils.instance.getComment(var))
        when CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end

        for group in vGroup.varGroups
          process_var_group(cls, bld, group)
        end
      end
    end

    def process_function(cls, bld, fun)
      return unless fun.elementId == CodeElem::ELEM_FUNCTION

      if fun.isTemplate
        templ = XCTEPlugin.findMethodPlugin('ruby', fun.name)
        if !templ.nil?
          bld.add(templ.get_definition(cls, ActiveComponent.get(), fun))
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'ruby
        end
      else # Must be empty function
        templ = XCTEPlugin.findMethodPlugin('ruby', 'method_empty')
        if !templ.nil?
          bld.add(templ.get_definition(fun, cfg))
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'ruby
        end
      end
    end
  end
end

XCTEPlugin.registerPlugin(XCTERuby::ClassStandard.new)
