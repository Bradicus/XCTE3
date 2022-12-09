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

require "plugins_core/lang_cpp/utils.rb"
require "plugins_core/lang_cpp/method_empty.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECpp
  class ClassStandard < ClassBase
    def initialize
      @name = "standard"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
      @activeVisibility = ""
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererCpp.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName())
      bld.lfExtension = Utils.instance.getExtension("header")
      genHeaderComment(cls, bld)
      genHeader(cls, bld)

      cppFile = SourceRendererCpp.new
      cppFile.lfName = Utils.instance.getStyledFileName(cls.getUName())
      cppFile.lfExtension = Utils.instance.getExtension("body")
      genHeaderComment(cls, cppFile)
      genBody(cls, cppFile)

      srcFiles << bld
      srcFiles << cppFile

      return srcFiles
    end

    def genHeaderComment(cls, bld)
      cfg = UserSettings.instance

      bld.add("/**")
      bld.add("* @class " + Utils.instance.getStyledClassName(cls.getUName()))

      if (UserSettings.instance.codeAuthor != nil)
        bld.add("* @author " + cfg.codeAuthor)
      end

      if UserSettings.instance.codeCompany != nil && cfg.codeCompany.size > 0
        bld.add("* " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.strip.size > 0
        bld.add("*")
        bld.add("* " + cfg.codeLicense)
      end

      bld.add("* ")

      if (cls.model.description != nil)
        cls.model.description.each_line { |descLine|
          if descLine.strip.size > 0
            bld.add("* " << descLine.strip)
          end
        }
      end

      bld.add("*/")
    end

    # Returns the code for the header for this class
    def genHeader(cls, bld)
      @activeVisibility = ""
      render_ifndef(cls, bld)

      # get list of includes needed by functions

      # Generate function dependencies
      render_fun_dependencies(cls, bld)
      render_dependencies(cls, bld)

      if cls.includes.length > 0
        bld.add
      end

      render_namespace_start(cls, bld)

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
        if var.arrayElemCount > 0
          bld.add("#define " << Utils.instance.getSizeConst(var) << " " << var.arrayElemCount.to_s)
        end
      }))

      if Utils.instance.hasAnArray(cls)
        bld.separate
      end

      for pd in cls.preDefs
        bld.add("class " + pd + ";")
      end

      classDec = "class " + Utils.instance.getStyledClassName(cls.getUName())

      inheritFrom = Array.new

      for bcls in cls.baseClasses
        inheritFrom.push(bcls.visibility + " " + Utils.instance.getClassTypeName(bcls))
      end

      for icls in cls.interfaces
        inheritFrom.push(icls.visibility + " " + Utils.instance.getClassTypeName(icls))
      end

      if (inheritFrom.length > 0)
        classDec += " : " + inheritFrom.join(", ")
      end

      bld.startClass(classDec)

      bld.indent

      # Generate class variables
      for group in cls.model.groups
        process_header_var_group(cls, bld, group, "public")
      end

      bld.separate

      for group in cls.model.groups
        process_header_var_group(cls, bld, group, "private")
      end

      bld.separate

      # Generate function declarations
      for funItem in cls.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION
          if funItem.visibility != @activeVisibility
            @activeVisibility = funItem.visibility
            bld.unindent
            bld.add(funItem.visibility + ":")
            bld.indent
          end

          if funItem.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
            if templ != nil
              if (funItem.isInline)
                templ.get_declaration_inline(cls, bld, funItem)
              else
                templ.get_declaration(cls, bld, funItem)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          else # Must be an empty function
            templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
            if templ != nil
              if (funItem.isInline)
                templ.get_declaration_inline(cls, bld, funItem)
              else
                templ.get_declaration(cls, bld, funItem)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        elsif funItem.elementId == CodeElem::ELEM_COMMENT
          bld.add(Utils.instance.getComment(funItem))
        elsif funItem.elementId == CodeElem::ELEM_FORMAT
          if (funItem.formatText == "\n")
            bld.add
          else
            bld.sameLine(funItem.formatText)
          end
        end
      end

      for group in cls.model.groups
        process_header_var_group_getter_setters(cls, bld, group)
      end

      bld.separate

      bld.unindent

      bld.add("//+XCTE Custom Code Area")
      bld.add
      bld.add("//-XCTE Custom Code Area")

      bld.endClass

      render_namespace_end(cls, bld)

      bld.add("#endif")
    end

    # process variable group
    def process_header_var_group(cls, bld, vGroup, vis)
      for var in vGroup.vars
        if var.visibility == vis
          if var.elementId == CodeElem::ELEM_VARIABLE
            if var.visibility != @activeVisibility
              @activeVisibility = var.visibility
              bld.unindent
              bld.add(var.visibility + ":")
              bld.indent
            end
            bld.add(Utils.instance.getVarDec(var))
          elsif var.elementId == CodeElem::ELEM_COMMENT
            bld.sameLine(Utils.instance.getComment(var))
          elsif var.elementId == CodeElem::ELEM_FORMAT
            bld.add(var.formatText)
          end
        end
      end

      for group in vGroup.groups
        process_header_var_group(cls, bld, group, vis)
      end
    end

    def process_header_var_group_getter_setters(cls, bld, vGroup)
      for var in vGroup.vars
        if "public" != @activeVisibility
          @activeVisibility = "public"
          bld.unindent
          bld.add("public:")
          bld.indent
        end

        if var.elementId == CodeElem::ELEM_VARIABLE
          if (var.genGet)
            templ = XCTEPlugin::findMethodPlugin("cpp", "method_get")
            if templ != nil
              templ.get_declaration(var, bld)
            end
          end
          if (var.genSet)
            templ = XCTEPlugin::findMethodPlugin("cpp", "method_set")
            if templ != nil
              templ.get_declaration(var, bld)
            end
          end
        end
      end

      for group in vGroup.groups
        process_header_var_group_getter_setters(cls, bld, group)
      end
    end

    # Returns the code for the body for this class
    def genBody(cls, bld)
      bld.add("#include \"" << Utils.instance.getStyledClassName(cls.getUName()) << ".h\"")
      bld.add

      render_namespace_start(cls, bld)

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
        if var.isStatic
          bld.add(Utils.instance.getTypeName(var) << " ")
          bld.sameLine(Utils.instance.getStyledClassName(cls.getUName()) << " :: ")
          bld.sameLine(Utils.instance.getStyledVariableName(var))

          if var.arrayElemCount.to_i > 0 # This is an array
            bld.sameLine("[" + Utils.instance.getSizeConst(var) << "]")
          elsif var.defaultValue != nil
            bld.sameLine(" = " + var.defaultValue)
          end

          bld.sameLine(";")
        end
      }))

      bld.add

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", fun.name)

            puts "processing template for function " + fun.name
            if templ != nil
              if (!fun.isInline)
                templ.get_definition(cls, bld, fun)
              end
            else
              #puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
            end
          else # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
            if templ != nil
              if (!fun.isInline)
                templ.get_definition(cls, bld, fun)
              end
            else
              #puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
            end
          end
        end
      end

      bld.add("//+XCTE Custom Code Area")
      bld.add
      bld.add("//-XCTE Custom Code Area")

      render_namespace_end(cls, bld)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECpp::ClassStandard.new)
