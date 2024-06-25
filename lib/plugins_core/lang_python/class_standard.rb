##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "class_standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_python/utils"
require "plugins_core/lang_python/x_c_t_e_python"

require "code_structure/code_elem_parent"
require "code_structure/code_elem_model"
require "lang_file"

module XCTEPython
  class ClassStandard < ClassBase
    def initialize
      @name = "class_standard"
      @language = "python"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      return cls.get_u_name
    end

    def gen_source_files(cls)
      srcFiles = []

      rend = SourceRendererPython.new
      rend.lfName = Utils.instance.style_as_file_name(cls.get_u_name)
      rend.lfExtension = Utils.instance.get_extension("body")
      genPythonFileComment(cls, rend)
      render_body_content(cls, rend)

      srcFiles << rend

      return srcFiles
    end

    def genPythonFileComment(cls, rend)
      cfg = UserSettings.instance

      rend.add("##")
      rend.add("# Class:: " + Utils.instance.style_as_file_name(cls.get_u_name))

      if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0
        rend.add("# " + cfg.codeCompany)
      end

      if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0
        rend.add("#\n# License:: " + cfg.codeLicense)
      end

      rend.add("# ")

      return if cls.model.description.nil?

      cls.model.description.each_line do |descLine|
        if descLine.strip.size > 0
          rend.add("# " << descLine.chomp)
        end
      end
    end

    def render_body_content(cls, bld)
      classDec = cls.model.visibility + " class " + get_class_name(cls)

      for par in (0..cls.base_classes.size)
        if par == 0 && !cls.base_classes[par].nil?
          classDec << " : " << cls.base_classes[par].visibility << " " << cls.base_classes[par].name
        elsif !cls.base_classes[par].nil?
          classDec << ", " << cls.base_classes[par].visibility << " " << cls.base_classes[par].name
        end
      end

      bld.start_class(classDec)

      # Process variables
      each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        XCTECSharp::Utils.instance.get_var_dec(var)
      }))

      bld.add if cls.functions.length > 0

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end

    # Returns the code for the header for this class
    def genPythonFileContent(cls, rend)
      headerString = String.new

      rend.add

      for inc in cls.includes
        rend.add("import " + inc.path + inc.name)
      end

      if !cls.includes.empty?
        rend.add
      end

      rend.start_class("class " + Utils.instance.style_as_file_name(cls.get_u_name))

      for var in varArray
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && var.isStatic == true
          rend.add(Utils.instance.get_styled_variable_name(var))
        end
      end

      rend.add

      # Generate code for functions
      for fun in cls.functions
        if fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION
          if fun.isTemplate
            templ = PluginManager.find_method_plugin("python", fun.name)
            if !templ.nil?
              templ.render_function(cls, fun, rend)
            else
              # puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
            end
          else # Must be empty function
            templ = PluginManager.find_method_plugin("python", "method_empty")
            if !templ.nil?
              templ.render_function(cls, fun, rend)
            else
              # puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
            end
          end
        end
      end

      rend.end_block("# class " + Utils.instance.style_as_file_name(cls.get_u_name))
      rend.add
    end
  end
end

XCTEPlugin.registerPlugin(XCTEPython::ClassStandard.new)
