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

require 'plugins_core/lang_python/utils'
require 'plugins_core/lang_python/x_c_t_e_python'
require 'code_elem'
require 'code_elem_parent'
require 'code_elem_model'
require 'lang_file'

module XCTEPython
  class ClassStandard < XCTEPlugin
    def initialize
      @name = 'standard'
      @language = 'python'
      @category = XCTEPlugin::CAT_CLASS
    end

    def gen_source_files(cls)
      srcFiles = []

      rend = SourceRendererPython.new
      rend.lfName = Utils.instance.get_styled_file_name(cls.getUName)
      rend.lfExtension = Utils.instance.get_extension('body')
      genPythonFileComment(cls, rend)
      genPythonFileContent(cls, rend)

      srcFiles << rend

      return srcFiles
    end

    def genPythonFileComment(cls, rend)
      rend.add('##')
      rend.add('# Class:: ' + Utils.instance.get_styled_file_name(cls.getUName))

      if !cfg.codeAuthor.nil?
        rend.add('# Author:: ' + cfg.codeAuthor)
      end

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

      rend.start_class('class ' + Utils.instance.get_styled_file_name(cls.getUName))

      # Do automatic static array size declairations at top of class
      varArray = []
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.isStatic == true
          rend.add(Utils.instance.get_styled_variable_name(var))
        end
      end

      rend.add

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin.findMethodPlugin('python', fun.name)
            if !templ.nil?
              templ.get_definition(cls, fun, rend)
            else
              # puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
            end
          else # Must be empty function
            templ = XCTEPlugin.findMethodPlugin('python', 'method_empty')
            if !templ.nil?
              templ.get_definition(cls, fun, rend)
            else
              # puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
            end
          end
        end
      end

      rend.end_block('# class ' + Utils.instance.get_styled_file_name(cls.getUName))
      rend.add
    end
  end
end

XCTEPlugin.registerPlugin(XCTEPython::ClassStandard.new)
