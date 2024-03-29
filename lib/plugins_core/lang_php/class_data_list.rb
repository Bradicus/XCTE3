##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "data list" classes

require 'plugins_core/lang_php/utils'
require 'plugins_core/lang_php/x_c_t_e_php'
require 'plugins_core/lang_php/method_data_list_display_edit'

require 'code_structure/code_elem_parent'
require 'lang_file'

module XCTEPhp
  class ClassDataList < XCTEPlugin
    def initialize
      @name = 'data_list'
      @language = 'php'
      @category = XCTEPlugin::CAT_CLASS
      @author = 'Brad Ottoson'
    end

    def gen_source_files(codeClass, _cfg)
      srcFiles = []

      # Now add on a list file for a list of these objects
      phpFile = LangFile.new
      phpFile.lfName = codeClass.name
      phpFile.lfExtension = XCTEPhp::Utils.get_extension('body')

      phpFile.add('<?php')
      phpFile.lfContents << genPhpFileComment(codeClass, outCode)
      phpFile.lfContents << genPhpSetValidateFileContent(codeClass, outCode)
      phpFile.add('?>')

      srcFiles << phpFile

      return srcFiles
    end

    def genPhpFileComment(codeClass, outCode)
      headerString = String.new

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
    def genPhpListFileContent(codeClass, _cfg)
      outCode.add

      outCode.add("include_once($GLOBALS['apr_libs'].'DataTypes/DataList.php');")
      # outCode.add("include_once($GLOBALS['apr_libs'].'DataTypes/GBEffectSet.php');")
      # outCode.add("include_once($GLOBALS['apr_libs'].'DataTypes/TechLocation.php');")

      for inc in codeClass.includesList
        outCode.add('include_once("' << inc.path << inc.name << '.php");')
      end

      if !codeClass.includesList.empty?
        outCode.add
      end

      if codeClass.has_an_array
        outCode.add
      end

      outCode.add('class ' << codeClass.name << ' extends DataList')
      outCode.add('{')

      outCode.add

      # Generate load from DB function
      outCode.add('    /**')
      outCode.add('    * Loads a ' << codeClass.name << ' list from a odf file')
      outCode.add('    */')
      outCode.add('    public function load($fName)')
      outCode.add('    {')
      outCode.add('        $this->fileName = $fName;')
      outCode.add('        $this->readODFFile($fName, new ' << codeClass.coreClass << '());')
      outCode.add('    }')

      outCode.add('    /**')
      outCode.add('    * Loads an ' << codeClass.name << ' list from a database file')
      outCode.add('    */')
      outCode.add('    public function loadDBTable($fName)')
      outCode.add('    {                    ')
      outCode.add('        readDBList($fName, new ' << codeClass.coreClass << '());')
      outCode.add('    }')

      outCode.add('}')
    end # genPhpListFileContent
  end
end

XCTEPlugin.registerPlugin(XCTEPhp::ClassDataList.new)
