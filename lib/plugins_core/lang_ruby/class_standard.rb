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

require "plugins_core/lang_ruby/x_c_t_e_ruby.rb"
require "plugins_core/lang_ruby/utils.rb"
require "plugins_core/lang_ruby/class_base.rb"
require "x_c_t_e_plugin.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "code_elem_model.rb"
require "lang_file.rb"
require "log"

module XCTERuby
  class ClassStandard < ClassBase
    def initialize
      @name = "standard"
      @language = "ruby"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererRuby.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def genFileComment(cls, bld)
      renderGlobalComment(cls.genCfg, bld)

      bld.separate

      bld.add("#")

      if (cls.description != nil)
        cls.description.each_line { |descLine|
          if descLine.strip.size > 0
            bld.add("# " + descLine.chomp)
          end
        }
      end
    end

    # Returns the code for the header for this class
    def genFileContent(cls, bld)
      bld.separate

      for inc in cls.includes
        bld.add("require '" << inc.path << inc.name << "." << Utils.instance.getExtension("body"))
      end

      bld.separate

      render_namespace_starts(cls, bld)

      inheritFrom = ""

      if cls.baseClasses.length > 0
        inheritFrom = " < " + Utils.instance.getClassTypeName(cls.baseClasses[0])
      end

      if cls.baseClasses.length > 1
        Log.error("Ruby doesn't support multiple inheritance")
      end

      bld.startClass("class " + getClassName(cls) + inheritFrom)

      accessors = Accessors.new
      # Do automatic static array size declairations at top of class
      process_var_accessors(accessors, cls, bld, cls.model.varGroup)

      add_accessors("attr_accessor", accessors.both, bld)
      add_accessors("attr_attr_reader", accessors.readers, bld)
      add_accessors("attr_attr_writer", accessors.writers, bld)

      bld.separate

      # Do automatic static array size declairations at top of class
      process_var_group(cls, bld, cls.model.varGroup)

      bld.separate
      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.endClass
      render_namespace_ends(cls, bld)
    end

    # process variable group
    def process_var_accessors(accessors, cls, bld, vGroup)
      for var in vGroup.vars
        if var.genGet || var.genSet
          accessors.add(Accessor.new(var, var.genGet, var.genSet))
        end

        for group in vGroup.varGroups
          process_var_accessors(accessors, cls, bld, group)
        end
      end
    end

    def add_accessors(accName, accList, bld)
      if accList.length > 0
        bld.add(accName + " :")
        bld.sameLine(get_accessor_var_list(accList).join(", :"))
      end
    end

    def get_accessor_var_list(accList)
      vList = Array.new

      for acc in accList
        vList.push(Utils.instance.getStyledVariableName(acc.var))
      end

      return vList
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add(Utils.instance.getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.sameLine(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
        for group in vGroup.varGroups
          process_var_group(cls, bld, group)
        end
      end
    end

    def process_function(cls, bld, fun)
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("ruby", fun.name)
          if templ != nil
            bld.add(templ.get_definition(cls, cfg))
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'ruby
          end
        else # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("ruby", "method_empty")
          if templ != nil
            bld.add(templ.get_definition(fun, cfg))
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'ruby
          end
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTERuby::ClassStandard.new)
