##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "XCTEPlugin" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_ruby/utils.rb"
require "plugins_core/lang_ruby/source_renderer_ruby.rb"
require "plugins_core/lang_ruby/x_c_t_e_ruby.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "code_elem_model.rb"
require "lang_file.rb"

module XCTERuby
  class ClassXCTEMethodPlugin < XCTEPlugin
    def initialize
      @name = "xcte_method_plugin"
      @language = "ruby"
      @category = XCTEPlugin::CAT_METHOD
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererRuby.new
      bld.lfName = lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    def genFileComment(cls, cfg, bld)
      if cfg.codeAuthor != nil
        bld.add("# Author:: " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        bld.add("# " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.size > 0
        bld.add("#")
        bld.add("# License:: " + cfg.codeLicense)
      end

      bld.add("#")

      if (cls.description != nil)
        cls.description.each_line { |descLine|
          if descLine.strip.size > 0
            headerString.add("# " + descLine.chomp)
          end
        }
      end
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      for inc in cls.includes
        bld.add("require '" + inc.path + inc.name + "." + Utils.instance.getExtension("body") + "'")
      end

      if !cls.includes.empty?
        bld.add
      end

      # Process namespace items
      if cls.namespaceList != nil
        for nsItem in cls.namespaceList
          bld.startBlock("module " << nsItem)
        end
      end

      bld.startClass("class " + Utils.instance.getStyledClassName(cls.getUName()) + " < XCTEPlugin")

      bld.startFunction("def initialize")
      bld.add('@name = "' + CodeNameStyling.styleUnderscoreLower(cls.getUName()) + '"')
      bld.add('@language = "' + cls.xmlElement.attributes["lang"] + '"')
      bld.add("@category = XCTEPlugin::CAT_METHOD")
      if cfg.codeAuthor
        bld.add('@author = "' + cfg.codeAuthor + '"')
      end
      bld.endFunction
      bld.add

      bld.add("# Returns the code for the content for this function")
      bld.startFunction("def get_definition(cls, cfg, bld)")

      bld.add("# process class variables")

      bld.startBlock("for group in cls.model.groups")
      bld.add("process_var_group(cls, cfg, bld, group)")
      bld.endBlock
      bld.endFunction

      bld.add

      bld.add("# process variable group")
      bld.startFunction("def process_var_group(cls, cfg, bld, vGroup)")
      bld.startBlock("for var in vGroup.vars")

      bld.startBlock("if var.elementId == CodeElem::ELEM_VARIABLE")
      bld.startBlock("if !var.isStatic   # Ignore static variables")
      bld.startBlock("if Utils.instance.isPrimitive(var)")
      bld.startBlock("if var.arrayElemCount.to_i > 0	# Array of primitives)")
      bld.add('bld.startBlock("for i in 0..@" << var.name << ".size")')
      bld.add('bld.add(var.name + "[i] = src" + cls.name + "[i]")')
      bld.add("bld.endBlock")

      bld.midBlock("else")
      bld.add('bld.add(var.name + " = " + "src" + cls.name + "." + var.name)')
      bld.endBlock

      bld.midBlock("else")
      bld.startBlock("if var.arrayElemCount > 0	# Array of objects")
      bld.add('bld.startBlock("for i in 0..@" << var.name << ".size")')
      bld.add('bld.add(var.name << "[i] = src" << cls.name << "[i]")')
      bld.add("bld.endBlock")

      bld.midBlock("else")
      bld.add('bld.add(var.name + " = " + "src" + cls.name + "." + var.name)')
      bld.endBlock
      bld.endBlock
      bld.endBlock

      bld.midBlock("elsif var.elementId == CodeElem::ELEM_COMMENT")
      bld.add("bld.add(Utils.instance.getComment(var))")
      bld.midBlock("elsif var.elementId == CodeElem::ELEM_FORMAT")
      bld.add("bld.add(var.formatText)")
      bld.endBlock

      bld.endBlock
      bld.startBlock("for group in vGroup")
      bld.add("process_var_group(cls, cfg, bld, group)")
      bld.endBlock
      bld.endFunction
      bld.endBlock

      # Process namespace items
      if cls.namespaceList != nil
        for nsItem in cls.namespaceList
          bld.endBlock
        end
      end

      bld.add

      prefix = cls.namespaceList.join("::")

      if (prefix.size > 0)
        prefix += "::"
      end

      bld.add("XCTEPlugin::registerPlugin(" + prefix + getClassName(cls) + ".new)")
    end
  end
end

XCTEPlugin::registerPlugin(XCTERuby::ClassXCTEMethodPlugin.new)
