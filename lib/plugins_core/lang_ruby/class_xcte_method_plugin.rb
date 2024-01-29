##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "XCTEPlugin" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require 'plugins_core/lang_ruby/utils'
require 'plugins_core/lang_ruby/source_renderer_ruby'
require 'plugins_core/lang_ruby/x_c_t_e_ruby'
require 'code_elem'
require 'code_elem_parent'
require 'code_elem_model'
require 'lang_file'

module XCTERuby
  class ClassXCTEMethodPlugin < ClassBase
    def initialize
      @name = 'xcte_method_plugin'
      @language = 'ruby'
      @category = XCTEPlugin::CAT_METHOD
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererRuby.new
      bld.lfName = lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')
      render_file_comment(cls, bld)
      gen_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def render_file_comment(cls, bld)
      bld.add('# Author:: ' + UserSettings.instance.codeAuthor) if !UserSettings.instance.codeAuthor.nil?

      if !UserSettings.instance.codeCompany.nil? && UserSettings.instance.codeCompany.size > 0
        bld.add('# ' + UserSettings.instance.codeCompany)
      end

      if !UserSettings.instance.codeLicense.nil? && UserSettings.instance.codeLicense.strip.size > 0
        bld.add('#')
        bld.add('# License:: ' + UserSettings.instance.codeLicense)
      end

      bld.add('#')

      return if cls.description.nil?

      cls.description.each_line do |descLine|
        headerString.add('# ' + descLine.chomp) if descLine.strip.size > 0
      end
    end

    # Returns the code for the content for this class
    def gen_body_content(cls, bld)
      for inc in cls.includes
        bld.add("require '" + inc.path + inc.name + '.' + Utils.instance.get_extension('body') + "'")
      end

      bld.add if !cls.includes.empty?

      # Process namespace items
      if cls.namespace.hasItems?
        for nsItem in cls.namespace.nsList
          bld.start_block('module ' << nsItem)
        end
      end

      bld.start_class('class ' + Utils.instance.get_styled_class_name(cls.getUName) + ' < XCTEPlugin')

      bld.start_function('def initialize')
      bld.add('@name = "' + CodeNameStyling.styleUnderscoreLower(cls.getUName) + '"')
      bld.add('@language = "' + cls.xmlElement.attributes['lang'] + '"')
      bld.add('@category = XCTEPlugin::CAT_METHOD')
      bld.add('@author = "' + UserSettings.instance.codeAuthor + '"') if UserSettings.instance.codeAuthor
      bld.endFunction
      bld.add

      bld.add('# Returns the code for the content for this function')
      bld.start_function('def get_definition(cls, bld, fun)')

      bld.add('# process class variables')

      bld.add('# Generate code for class variables')
      bld.add('each_var(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|')

      bld.start_block('if !var.isStatic   # Ignore static variables')
      bld.start_block('if Utils.instance.is_primitive(var)')
      bld.start_block("if var.arrayElemCount.to_i > 0\t# Array of primitives)")
      bld.add('bld.start_block("for i in 0..@" << var.name << ".size")')
      bld.add('bld.add(var.name + "[i] = src" + cls.name + "[i]")')
      bld.add('bld.end_block')

      bld.mid_block('else')
      bld.add('bld.add(var.name + " = " + "src" + cls.name + "." + var.name)')
      bld.end_block

      bld.mid_block('else')
      bld.start_block("if var.arrayElemCount > 0\t# Array of objects")
      bld.add('bld.start_block("for i in 0..@" << var.name << ".size")')
      bld.add('bld.add(var.name << "[i] = src" << cls.name << "[i]")')
      bld.add('bld.end_block')

      bld.mid_block('else')
      bld.add('bld.add(var.name + " = " + "src" + cls.name + "." + var.name)')
      bld.end_block
      bld.end_block
      bld.end_block

      bld.add('}))')
      bld.end_block
      bld.end_block

      # Process namespace items
      if cls.namespace.hasItems?
        for nsItem in cls.namespace.nsList
          bld.end_block
        end
      end

      bld.add

      prefix = cls.namespace.get('::')

      prefix += '::' if prefix.size > 0

      bld.add('XCTEPlugin::registerPlugin(' + prefix + get_class_name(cls) + '.new)')
    end
  end
end

XCTEPlugin.registerPlugin(XCTERuby::ClassXCTEMethodPlugin.new)
