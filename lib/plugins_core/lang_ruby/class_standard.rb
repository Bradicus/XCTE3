##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require 'plugins_core/lang_ruby/utils.rb'
require 'plugins_core/lang_ruby/x_c_t_e_ruby.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'code_elem_model.rb'
require 'lang_file.rb'

class XCTERuby::ClassStandard < XCTEPlugin
  def initialize
    XCTERuby::Utils::init

    @name = "standard"
    @language = "ruby"
    @category = XCTEPlugin::CAT_CLASS
    @author = "Brad Ottoson"
  end

  def genSourceFiles(codeClass, cfg)
    srcFiles = Array.new

    rubyFile = LangFile.new
    rubyFile.lfName = codeClass.name
    rubyFile.lfExtension = XCTERuby::Utils::getExtension('body')
    rubyFile.lfContents = genRubyFileComment(codeClass, cfg)
    rubyFile.lfContents << genRubyFileContent(codeClass, cfg)

    srcFiles << rubyFile

    return srcFiles
  end

  def genRubyFileComment(codeClass, cfg)
    headerString = String.new

    headerString << "##\n";
    headerString << "# Class:: " + codeClass.name + "\n";

    if (cfg.codeAuthor != nil)
      headerString << "# Author:: " + cfg.codeAuthor + "\n";
    end

    if cfg.codeCompany != nil && cfg.codeCompany.size > 0
      headerString << "# " + cfg.codeCompany + "\n";
    end

    if cfg.codeLicense != nil && cfg.codeLicense.size > 0
      headerString << "#\n# License:: " + cfg.codeLicense + "\n";
    end

    headerString << "# \n";

    if (codeClass.description != nil)
      codeClass.description.each_line { |descLine|
        if descLine.strip.size > 0
          headerString << "# " << descLine.chomp << "\n";
        end
      }
    end

    return(headerString);
  end

  # Returns the code for the header for this class
  def genRubyFileContent(codeClass, cfg)
    headerString = String.new

    headerString << "\n";

    for inc in codeClass.includesList
      headerString << "require '" << inc.path << inc.name << "." << XCTERuby::Utils::getExtension('body') << "'\n"
    end

    if !codeClass.includesList.empty?
      headerString << "\n"
    end

    if codeClass.hasAnArray
      headerString << "\n"
    end

    headerString << "class " << codeClass.name << "\n"
    
    # Do automatic static array size declairations at top of class
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount > 0
        headerString << "    " << XCTERuby::Utils::getSizeConst(var) << " = " << var.arrayElemCount.to_s << "\n"
      end
    end

    if codeClass.hasAnArray
      headerString << "\n"  # If we declaired array size variables add a seperator
    end

    # Generate class variables
    headerString << "    # -- Variables --\n"

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        headerString << "    " << XCTERuby::Utils::getVarDec(var);
      elsif var.elementId == CodeElem::ELEM_COMMENT
        headerString << "    " <<  XCTERuby::Utils::getComment(var)
      elsif var.elementId == CodeElem::ELEM_FORMAT
        headerString << var.formatText
      end
    end

    headerString << "\n"

    # Generate code for functions
    for fun in codeClass.functionSection
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("ruby", fun.name)
          if templ != nil
            headerString << templ.get_definition(codeClass, cfg)
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
          end
        else  # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("ruby", "method_empty")
          if templ != nil
            headerString << templ.get_definition(fun, cfg)
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
          end
        end
      end
    end

    headerString << "end  # class " << codeClass.name << "\n\n";

    return(headerString);
  end

end

XCTEPlugin::registerPlugin(XCTERuby::ClassStandard.new)
