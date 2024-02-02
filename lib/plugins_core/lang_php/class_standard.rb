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

require 'plugins_core/lang_php/utils'
require 'plugins_core/lang_php/x_c_t_e_php'
require 'code_elem'
require 'code_elem_parent'
require 'lang_file'

class XCTEPhp::ClassStandard < XCTEPlugin
  def initialize
    @name = 'standard'
    @language = 'php'
    @category = XCTEPlugin::CAT_CLASS
  end

  def gen_source_files(codeClass, _cfg)
    srcFiles = []

    phpFile = LangFile.new
    phpFile.lfName = codeClass.name
    phpFile.lfExtension = XCTEPhp::Utils.get_extension('body')

    phpFile.add('<?php')
    genPhpFileComment(codeClass, phpFile)
    genPhpFileContent(codeClass, phpFile)
    phpFile.add('?>')

    srcFiles << phpFile

    return srcFiles
  end

  def genPhpFileComment(codeClass, outCode)
    outCode.add('/**')
    outCode.add('* @class ' + codeClass.name)

    if !cfg.codeAuthor.nil?
      outCode.add('* @author ' + cfg.codeAuthor)
    end

    if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0
      outCode.add('* ' + cfg.codeCompany)
    end

    if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0
      outCode.add("*\n* " + cfg.codeLicense)
    end

    outCode.add('* ')

    if !codeClass.description.nil?
      codeClass.description.each_line do |descLine|
        if descLine.strip.size > 0
          outCode.add('* ' << descLine.chomp)
        end
      end
    end

    outCode.add('*/')
  end

  # Returns the code for the header for this class
  def genPhpFileContent(codeClass, outCode)
    headerString = String.new

    outCode.add

    for inc in codeClass.includesList
      outCode.add('include_once("' << inc.path << inc.name << '.php");')
    end

    if !codeClass.includesList.empty?
      outCode.add('')
    end

    if codeClass.has_an_array
      outCode.add('')
    end

    outCode.add('class ' << codeClass.name)
    outCode.add('{')

    outCode.add

    # Generate code for functions
    for fun in codeClass.functionSection
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin.findMethodPlugin('php', fun.name)
          if !templ.nil?
            templ.render_function(codeClass, outCode)
          else
            # puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
          end
        else # Must be empty function
          templ = XCTEPlugin.findMethodPlugin('php', 'method_empty')
          if !templ.nil?
            templ.render_function(fun, outCode)
          else
            # puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
          end
        end
      end
    end

    outCode.add('}')
  end
end

XCTEPlugin.registerPlugin(XCTEPhp::ClassStandard.new)
