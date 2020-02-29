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

require 'plugins_core/lang_python/utils.rb'
require 'plugins_core/lang_python/x_c_t_e_python.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'code_elem_model.rb'
require 'lang_file.rb'

module XCTEPython
  class ClassStandard < XCTEPlugin
    def initialize
      @name = "standard"
      @language = "python"
      @category = XCTEPlugin::CAT_CLASS
    end

    def genSourceFiles(dataModel, genClass, cfg)
      srcFiles = Array.new

      rend = SourceRendererPython.new
      rend.lfName = Utils.instance.getStyledFileName(dataModel.name)
      rend.lfExtension = Utils.instance.getExtension('body')
      genPythonFileComment(dataModel, genClass, cfg, rend)
      genPythonFileContent(dataModel, genClass, cfg, rend)

      srcFiles << rend

      return srcFiles
    end

    def genPythonFileComment(dataModel, genClass, cfg, rend)
      
      rend.add("##")
      rend.add("# Class:: " + Utils.instance.getStyledFileName(dataModel.name))

      if (cfg.codeAuthor != nil)
        rend.add("# Author:: " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        rend.add("# " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.size > 0
        rend.add("#\n# License:: " + cfg.codeLicense)
      end

      rend.add("# ")

      if (dataModel.description != nil)
        dataModel.description.each_line { |descLine|
          if descLine.strip.size > 0
            rend.add("# " << descLine.chomp)
          end
        }
      end
    end

    # Returns the code for the header for this class
    def genPythonFileContent(dataModel, genClass, cfg, rend)
      headerString = String.new

      rend.add

      for inc in genClass.includes
        rend.add("import " + inc.path + inc.name)
      end

      if !genClass.includes.empty?
        rend.add
      end

      rend.startClass("class " +  Utils.instance.getStyledFileName(dataModel.name))
      
      # Do automatic static array size declairations at top of class
      varArray = Array.new
      dataModel.getAllVarsFor(varArray);

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.isStatic == true
          rend.add(Utils.instance.getStyledVariableName(var))
        end
      end

      rend.add

      # Generate code for functions
      for fun in genClass.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("python", fun.name)
            if templ != nil
              templ.get_definition(dataModel, genClass, fun, rend)
            else
              #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
            end
          else  # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("python", "method_empty")
            if templ != nil
              templ.get_definition(dataModel, genClass, fun, rend)
            else
              #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
            end
          end
        end
      end

      rend.endBlock("# class " + Utils.instance.getStyledFileName(dataModel.name))
      rend.add
    end

  end
end

XCTEPlugin::registerPlugin(XCTEPython::ClassStandard.new)
