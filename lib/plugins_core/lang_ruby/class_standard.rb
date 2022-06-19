##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_ruby/x_c_t_e_ruby.rb"
require "plugins_core/lang_ruby/utils.rb"
require "x_c_t_e_plugin.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "code_elem_model.rb"
require "lang_file.rb"

module XCTERuby
  class ClassStandard < XCTEPlugin
    def initialize
      @name = "standard"
      @language = "ruby"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.model.name
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      rubyFile = LangFile.new
      rubyFile.lfName = cls.name
      rubyFile.lfExtension = Utils.instance.getExtension("body")
      rubyFile.lfContents = genRubyFileComment(cls, cfg)
      rubyFile.lfContents << genRubyFileContent(cls, cfg)

      srcFiles << rubyFile

      return srcFiles
    end

    def genRubyFileComment(cls, cfg)
      headerString = String.new

      headerString << "##\n"
      headerString << "# Class:: " + cls.name + "\n"

      if (cfg.codeAuthor != nil)
        headerString << "# Author:: " + cfg.codeAuthor + "\n"
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        headerString << "# " + cfg.codeCompany + "\n"
      end

      if cfg.codeLicense != nil && cfg.codeLicense.size > 0
        headerString << "#\n# License:: " + cfg.codeLicense + "\n"
      end

      headerString << "# \n"

      if (cls.description != nil)
        cls.description.each_line { |descLine|
          if descLine.strip.size > 0
            headerString << "# " << descLine.chomp << "\n"
          end
        }
      end

      return(headerString)
    end

    # Returns the code for the header for this class
    def genRubyFileContent(cls, cfg)
      headerString = String.new

      headerString << "\n"

      for inc in cls.includes
        headerString << "require '" << inc.path << inc.name << "." << Utils.instance.getExtension("body") << "'\n"
      end

      if !cls.includes.empty?
        headerString << "\n"
      end

      if cls.model.hasAnArray
        headerString << "\n"
      end

      headerString << "class " << getClassName(cls) << "\n"

      # Do automatic static array size declairations at top of class
      varArray = Array.new varArray = Array.new

      for vGrp in cls.model.groups
        CodeStructure::CodeElemModel.getVarsFor(vGrp, varArray)
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount > 0
          hFile.add("#define " << Utils.instance.getSizeConst(var) << " " << var.arrayElemCount.to_s)
        end
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount > 0
          headerString << "    " << Utils.instance.getSizeConst(var) << " = " << var.arrayElemCount.to_s << "\n"
        end
      end

      if cls.model.hasAnArray
        headerString << "\n"  # If we declaired array size variables add a seperator
      end

      # Generate class variables
      headerString << "    # -- Variables --\n"

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          headerString << "    " << Utils.instance.getVarDec(var)
        elsif var.elementId == CodeElem::ELEM_COMMENT
          headerString << "    " << Utils.instance.getComment(var)
        elsif var.elementId == CodeElem::ELEM_FORMAT
          headerString << var.formatText
        end
      end

      headerString << "\n"

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("ruby", fun.name)
            if templ != nil
              headerString << templ.get_definition(cls, cfg)
            else
              #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
            end
          else # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("ruby", "method_empty")
            if templ != nil
              headerString << templ.get_definition(fun, cfg)
            else
              #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
            end
          end
        end
      end

      headerString << "end  # class " << cls.name << "\n\n"

      return(headerString)
    end
  end
end

XCTEPlugin::registerPlugin(XCTERuby::ClassStandard.new)
