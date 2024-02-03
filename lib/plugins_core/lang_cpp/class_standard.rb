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

require 'plugins_core/lang_cpp/utils'
require 'plugins_core/lang_cpp/method_empty'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'

require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'
require 'log'

module XCTECpp
  class ClassStandard < ClassBase
    def initialize
      @name = 'standard'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_CLASS
      @activeVisibility = ''
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererCpp.new
      bld.lfName = Utils.instance.get_styled_file_name(cls.getUName)
      bld.lfExtension = Utils.instance.get_extension('header')
      genHeaderComment(cls, bld)
      genHeader(cls, bld)

      cppFile = SourceRendererCpp.new
      cppFile.lfName = Utils.instance.get_styled_file_name(cls.getUName)
      cppFile.lfExtension = Utils.instance.get_extension('body')
      genHeaderComment(cls, cppFile)
      genBody(cls, cppFile)

      srcFiles << bld
      srcFiles << cppFile

      srcFiles
    end

    def genHeaderComment(cls, bld)
      cfg = UserSettings.instance

      bld.add('/**')
      bld.add('* @class ' + Utils.instance.get_styled_class_name(cls.getUName))

      bld.add('* @author ' + cfg.codeAuthor) if !UserSettings.instance.codeAuthor.nil?

      bld.add('* ' + cfg.codeCompany) if !UserSettings.instance.codeCompany.nil? && cfg.codeCompany.size > 0

      if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0
        bld.add('*')
        bld.add('* ' + cfg.codeLicense)
      end

      bld.add('* ')

      if !cls.model.description.nil?
        cls.model.description.each_line do |descLine|
          bld.add('* ' << descLine.strip) if descLine.strip.size > 0
        end
      end

      bld.add('*/')
    end

    # Returns the code for the header for this class
    def genHeader(cls, bld)
      @activeVisibility = ''
      render_ifndef(cls, bld)

      # get list of includes needed by functions

      # Generate function dependencies
      render_fun_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.add if cls.includes.length > 0

      render_namespace_start(cls, bld)

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          bld.add('#define ' << Utils.instance.get_size_const(var) << ' ' << var.arrayElemCount.to_s)
        end
      }))

      bld.separate if Utils.instance.has_an_array?(cls)

      for pd in cls.preDefs
        bld.add('class ' + pd + ';')
      end

      classDec = 'class ' + Utils.instance.get_styled_class_name(cls.getUName)

      inheritFrom = []

      for bcls in cls.base_classes
        inheritFrom.push(bcls.visibility + ' ' + Utils.instance.getClassTypeName(bcls))
      end

      for icls in cls.interfaces
        inheritFrom.push(icls.visibility + ' ' + Utils.instance.getClassTypeName(icls))
      end

      classDec += ' : ' + inheritFrom.join(', ') if inheritFrom.length > 0

      bld.start_class(classDec)

      bld.indent

      # Generate class variables
      process_header_var_group(cls, bld, cls.model.varGroup, 'public')

      bld.separate

      process_header_var_group(cls, bld, cls.model.varGroup, 'private')

      bld.separate

      # Generate function declarations
      for funItem in cls.functions
        if funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION
          if funItem.visibility != @activeVisibility
            @activeVisibility = funItem.visibility
            bld.unindent
            bld.add(funItem.visibility + ':')
            bld.indent
          end

          if funItem.isTemplate
            templ = XCTEPlugin.findMethodPlugin('cpp', funItem.name)
            if !templ.nil?
              if funItem.isInline
                templ.get_declaration_inline(cls, bld, funItem)
              else
                templ.get_declaration(cls, bld, funItem)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          else # Must be an empty function
            templ = XCTEPlugin.findMethodPlugin('cpp', 'method_empty')
            if !templ.nil?
              if funItem.isInline
                templ.get_declaration_inline(cls, bld, funItem)
              else
                templ.get_declaration(cls, bld, funItem)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
          bld.add(Utils.instance.getComment(funItem))
        elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
          if funItem.formatText == "\n"
            bld.add
          else
            bld.same_line(funItem.formatText)
          end
        end
      end

      process_header_var_group_getter_setters(cls, bld, cls.model.varGroup)

      bld.separate

      bld.unindent

      bld.add('//+XCTE Custom Code Area')
      bld.add
      bld.add('//-XCTE Custom Code Area')

      bld.end_class

      render_namespace_end(cls, bld)

      bld.add('#endif')
    end

    # process variable group
    def process_header_var_group(cls, bld, _vGroup, _vis)
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.visibility != @activeVisibility
          @activeVisibility = var.visibility
          bld.unindent
          bld.add(var.visibility + ':')
          bld.indent
        end

        bld.add(Utils.instance.get_var_dec(var))
      }))
    end

    def process_header_var_group_getter_setters(cls, bld, vGroup)
      for var in vGroup.vars
        if 'public' != @activeVisibility
          @activeVisibility = 'public'
          bld.unindent
          bld.add('public:')
          bld.indent
        end

        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          if var.genGet
            templ = XCTEPlugin.findMethodPlugin('cpp', 'method_get')
            templ.get_declaration(var, bld) if !templ.nil?
          end
          if var.genSet
            templ = XCTEPlugin.findMethodPlugin('cpp', 'method_set')
            templ.get_declaration(var, bld) if !templ.nil?
          end
        end
      end

      for group in vGroup.varGroups
        process_header_var_group_getter_setters(cls, bld, group)
      end
    end

    # Returns the code for the body for this class
    def genBody(cls, bld)
      bld.add('#include "' << Utils.instance.get_styled_class_name(cls.getUName) << '.h"')
      bld.add

      render_namespace_start(cls, bld)

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.isStatic
          bld.add(Utils.instance.get_type_name(var) << ' ')
          bld.same_line(Utils.instance.get_styled_class_name(cls.getUName) << ' :: ')
          bld.same_line(Utils.instance.get_styled_variable_name(var))

          if var.arrayElemCount.to_i > 0 # This is an array
            bld.same_line('[' + Utils.instance.get_size_const(var) << ']')
          elsif !var.defaultValue.nil?
            bld.same_line(' = ' + var.defaultValue)
          end

          bld.same_line(';')
        end
      }))

      bld.add

      # Generate code for functions
      for fun in cls.functions
        if fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin.findMethodPlugin('cpp', fun.name)

            Log.debug('processing template for function ' + fun.name)
            if !templ.nil?
              templ.render_function(cls, bld, fun) if !fun.isInline
            else
              # puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
            end
          else # Must be empty function
            templ = XCTEPlugin.findMethodPlugin('cpp', 'method_empty')
            if !templ.nil?
              templ.render_function(cls, bld, fun) if !fun.isInline
            else
              # puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
            end
          end
        end
      end

      bld.add('//+XCTE Custom Code Area')
      bld.add
      bld.add('//-XCTE Custom Code Area')

      render_namespace_end(cls, bld)
    end
  end
end

XCTEPlugin.registerPlugin(XCTECpp::ClassStandard.new)
