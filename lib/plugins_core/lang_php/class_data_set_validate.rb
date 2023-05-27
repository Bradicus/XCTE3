##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for a data set(basically any class)
# validator class

require "plugins_core/lang_php/utils.rb"
require "plugins_core/lang_php/x_c_t_e_php.rb"
require "plugins_core/lang_php/method_data_list_display_edit.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "lang_file.rb"

module XCTEPhp
  class ClassDataSetValidate < XCTEPlugin
    def initialize
      @name = "data_set_validator"
      @language = "php"
      @category = XCTEPlugin::CAT_CLASS
      @author = "Brad Ottoson"
    end

    def genSourceFiles(codeClass, cfg)
      srcFiles = Array.new

      # Now add on a list file for a list of these objects
      phpFile = LangFile.new
      phpFile.lfName = codeClass.name
      phpFile.lfExtension = XCTEPhp::Utils::getExtension("body")

      phpFile.add("<?php")
      phpFile.lfContents << genPhpFileComment(codeClass, outCode)
      phpFile.lfContents << genPhpSetValidateFileContent(codeClass, outCode)
      phpFile.add("?>")

      srcFiles << phpFile

      return srcFiles
    end

    def genPhpFileComment(codeClass, outCode)
      headerString = String.new

      outCode.add("/**")
      outCode.add("* @class " + codeClass.name)

      if (cfg.codeAuthor != nil)
        outCode.add("* @author " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        outCode.add("* " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.strip.size > 0
        outCode.add("*\n* " + cfg.codeLicense)
      end

      outCode.add("* ")

      if (codeClass.description != nil)
        codeClass.description.each_line { |descLine|
          if descLine.strip.size > 0
            outCode.add("* " << descLine.chomp)
          end
        }
      end

      outCode.add("*/")
    end

    # Returns the code for the header for this class
    def genPhpSetValidateFileContent(codeClassValidator, cfg)
      headerString = String.new

      listInfo = XCTEPhp::Utils::getDataListInfo(codeClassValidator.xmlElement)
      listPath = File.dirname(codeClassValidator.path)

      codeClass = ClassModelManager.findClass(codeClassValidator.coreClass)

      outCode.add

      outCode.add("include_once($GLOBALS['apr_libs'].'Validators/GlobalValidation.php');")

      for inc in codeClass.includesList
        outCode.add('include_once("' << inc.path << inc.name << ".php\");")
      end

      outCode.add('include_once("' << codeClass.name << ".php\");")

      if !codeClass.includesList.empty?
        outCode.add
      end

      if codeClass.hasAnArray
        outCode.add
      end

      outCode.add("class " << codeClassValidator.name)
      outCode.add("{")

      outCode.add

      # Generate load from DB function
      outCode.add("    /**")
      outCode.add("    * Validates a " << codeClass.name << " class")
      outCode.add("    */")
      outCode.add("    public static function validate($v" << codeClass.name << "Obj" << ", $errorList, $tableRowNum)")
      outCode.add("    {")

      varArray = Array.new
      codeClass.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          outCode.add("        // if (isset($v" << codeClass.name << 'Obj->dataSet["' << var.name << '"])) ')

          outCode.add(var.vtype << "Validator::validate($v" << codeClass.name << 'Obj->dataSet["' << var.name << '"], $errorList, $tableRowNum);')
          outCode.add('        // else $errorList []= ErrorData::genError("Undefined element ", $tableRowNum, "required element ' << var.name << " has not been defined\");")
        elsif var.elementId == CodeElem::ELEM_FORMAT
          outCode.addvar.formatText
        end
      end

      outCode.iadd(1, "        // ValidatorDisplay::displayResults($errorList);")

      outCode.add("    }")

      outCode.add("}")
    end # genPhpListFileContent
  end
end

XCTEPlugin::registerPlugin(XCTEPhp::ClassDataSetValidate.new)
