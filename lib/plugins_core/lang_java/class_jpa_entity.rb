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

require "plugins_core/lang_java/utils.rb"
require "plugins_core/lang_java/x_c_t_e_java.rb"
require "plugins_core/lang_java/class_base.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "code_elem_model.rb"
require "lang_file.rb"

module XCTEJava
  class ClassJpaEntity < ClassBase
    def initialize
      @name = "class_jpa_entity"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererCSharp.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      process_dependencies(cls, bld)

      render_package_start(cls, bld)
      render_dependencies(cls, bld)

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addUse("jakarta.persistence.*")
      super
    end

    def genFileComment(cls, bld)
      cfg = UserSettings.instance

      bld.add("/**")
      bld.add("* @class " + cls.name)

      if (cfg.codeAuthor != nil)
        bld.add("* @author " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        bld.add("* " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.strip.size > 0
        bld.add("*\n* " + cfg.codeLicense)
      end

      bld.add("*")

      if (cls.description != nil)
        cls.description.each_line { |descLine|
          if descLine.strip.size > 0
            bld.add("* " << descLine.chomp)
          end
        }
      end

      bld.add("*/")
      bld.separate
    end

    # Returns the code for the header for this class
    def genFileContent(cls, bld)
      bld.separate
      clsName = getClassName(cls)
      tableName = XCTESql::Utils.instance.getStyledTableName(cls.getUName())

      bld.add("@Entity")
      if (tableName != clsName)
        bld.add('@Table(name="' + tableName + '")')
      end
      bld.startClass("public class " + clsName)

      eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          bld.add("public static final int " + Utils.instance.getSizeConst(var) + " = " << var.arrayElemCount.to_s + ";")
        end
      }))

      if Utils.instance.hasAnArray(cls)
        bld.separate
      end

      # Generate class variables
      eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if (var.name == "id")
          bld.add("@Id")
          bld.add("@GeneratedValue(strategy=GenerationType.AUTO)")
          bld.add(Utils.instance.getVarDec(var))
        else
          for attrib in var.attribs
            bld.add("@" + attrib.name)
          end
          bld.add(Utils.instance.getVarDec(var))
        end
      }))

      bld.separate

      render_functions(cls, bld)
      render_header_var_group_getter_setters(cls, bld)

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTEJava::ClassJpaEntity.new)
