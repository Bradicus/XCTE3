##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for a json_engine classes

require 'plugins_core/lang_cpp/utils'
require 'plugins_core/lang_cpp/method_empty'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'

require 'code_structure/code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'
require 'log'

module XCTECpp
  class ClassPugiXmlEngine < ClassBase
    def initialize
      @name = 'pugixml_engine'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + ' pugi xml engine'
    end

    def gen_source_files(cls)
      srcFiles = []

      hFile = SourceRendererCpp.new
      hFile.lfName = Utils.instance.style_as_file_name(cls.get_u_name + 'PugiXmlEngine')
      hFile.lfExtension = Utils.instance.get_extension('header')
      genHeaderComment(cls, hFile)
      genHeader(cls, hFile)

      cppFile = SourceRendererCpp.new
      cppFile.lfName = Utils.instance.style_as_file_name(cls.get_u_name + 'PugiXmlEngine')
      cppFile.lfExtension = Utils.instance.get_extension('body')
      genHeaderComment(cls, cppFile)
      genBody(cls, cppFile)

      srcFiles << hFile
      srcFiles << cppFile

      srcFiles
    end

    def genHeaderComment(cls, hFile)
      hFile.add('/**')
      hFile.add('* @class ' + get_class_name(cls))

      hFile.add('* @author ' + cfg.codeAuthor) if !cfg.codeAuthor.nil?

      hFile.add('* ' + cfg.codeCompany) if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0

      if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0
        hFile.add('*')
        hFile.add('* ' + cfg.codeLicense)
      end

      hFile.add('* ')

      if !cls.model.description.nil?
        cls.model.description.each_line do |descLine|
          hFile.add('* ' << descLine.strip) if descLine.strip.size > 0
        end
      end

      hFile.add('*/')
    end

    # Returns the code for the header for this class
    def genHeader(cls, hFile)
      render_ifndef(cls, hFile)

      # get list of includes needed by functions

      # Generate function declarations
      for funItem in cls.functions
        if funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION && funItem.isTemplate
          templ = XCTEPlugin.findMethodPlugin('cpp', funItem.name)
          if !templ.nil?
            templ.process_dependencies(cls, funItem, hFile)
          else
            # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
          end
        end
      end

      process_dependencies(cls, bld)

      hFile.add if cls.includes.length > 0

      # Process namespace items
      if cls.namespace.hasItems?
        for nsItem in cls.namespace.ns_list
          hFile.start_block('namespace ' << nsItem)
        end
        hFile.add
      end

      # Do automatic static array size declairations above class def

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          hFile.add('#define ' << Utils.instance.get_size_const(var) << ' ' << var.arrayElemCount.to_s)
        end
      }))

      hFile.separate if Utils.instance.has_an_array?(cls)

      classDec = 'class ' + cls.name

      for par in (0..cls.baseClassModelManager.size)
        nameSp = ''
        if par == 0 && !cls.base_classes[par].nil?
          classDec << ' : '
        elsif !cls.base_classes[par].nil?
          classDec << ', '
        end

        if !cls.base_classes[par].nil?
          if cls.base_classes[par].namespace.hasItems? && cls.base_classes[par].namespace.ns_list.size > 0
            nameSp = cls.base_classes[par].namespace.get('::') + '::'
          end

          classDec << cls.base_classes[par].visibility << ' ' << nameSp << Utils.instance.style_as_class(cls.base_classes[par].name)
        end
      end

      hFile.start_class(classDec)

      hFile.add('public:')
      hFile.indent

      # Generate class variables

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        hFile.add(Utils.instance.get_var_dec(var)) if var.arrayElemCount > 0
      }))

      hFile.add if cls.functions.length > 0

      # Generate function declarations
      for funItem in cls.functions
        if funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION
          if funItem.isTemplate
            templ = XCTEPlugin.findMethodPlugin('cpp', funItem.name)
            if !templ.nil?
              if funItem.isInline
                templ.get_declaration_inline(cls, funItem, hFile)
              else
                templ.get_declaration(cls, funItem, hFile)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          else # Must be an empty function
            templ = XCTEPlugin.findMethodPlugin('cpp', 'method_empty')
            if !templ.nil?
              if funItem.isInline
                templ.get_declaration_inline(cls, funItem, hFile)
              else
                templ.get_declaration(cls, funItem, hFile)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
          hFile.add(Utils.instance.get_comment(funItem))
        elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
          if funItem.formatText == "\n"
            hFile.add
          else
            hFile.same_line(funItem.formatText)
          end
        end
      end

      hFile.unindent

      hFile.end_class

      render_namespace_end(cls, hFile)

      hFile.separate
      hFile.add('#endif')
    end

    # Returns the code for the body for this class
    def genBody(cls, cppGen)
      cppGen.add('#include "' << Utils.instance.style_as_class(cls.get_u_name) << '.h"')
      cppGen.add

      render_namespace_start(cls, cppGen)

      # Initialize static variables
      varArray = []
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && var.isStatic
          cppGen.add(Utils.instance.get_type_name(var) << ' ')
          cppGen.same_line(Utils.instance.style_as_class(cls.get_u_name) << ' :: ')
          cppGen.same_line(Utils.instance.get_styled_variable_name(var))

          if var.arrayElemCount.to_i > 0 # This is an array
            cppGen.same_line('[' + Utils.instance.get_size_const(var) << ']')
          end

          cppGen.same_line(';')
        end
      end

      cppGen.add

      # Generate code for functions
      for fun in cls.functions
        if fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin.findMethodPlugin('cpp', fun.name)

            Log.debug('processing template for function ' + fun.name)
            if !templ.nil?
              templ.render_function(cls, fun, cppGen) if !fun.isInline
            else
              # puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
            end
          else # Must be empty function
            templ = XCTEPlugin.findMethodPlugin('cpp', 'method_empty')
            if !templ.nil?
              templ.render_function(cls, fun, cppGen) if !fun.isInline
            else
              # puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
            end
          end
        end
      end

      render_namespace_end(cls, cppGen)
    end
  end
end

XCTEPlugin.registerPlugin(XCTECpp::ClassPugiXmlEngine.new)
