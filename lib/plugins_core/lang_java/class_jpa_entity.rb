##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for jpa entity classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require 'plugins_core/lang_java/utils'
require 'plugins_core/lang_java/x_c_t_e_java'
require 'plugins_core/lang_java/class_base'
require 'code_elem'
require 'code_elem_parent'
require 'code_elem_model'
require 'lang_file'

module XCTEJava
  class ClassJpaEntity < ClassBase
    def initialize
      super

      @name = 'class_jpa_entity'
      @language = 'java'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererJava.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')

      process_dependencies(cls, bld)

      render_package_start(cls, bld)
      render_dependencies(cls, bld)

      gen_file_comment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addUse('jakarta.persistence.*')
      super
    end

    # Returns the code for the header for this class
    def genFileContent(cls, bld)
      bld.separate
      clsName = getClassName(cls)
      tableName = XCTESql::Utils.instance.getStyledTableName(cls.getUName)

      bld.add('@Entity')
      bld.add('@Table(name="' + tableName + '")') if tableName != clsName
      bld.start_class('public class ' + clsName)

      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          bld.add('public static final int ' + Utils.instance.getSizeConst(var) + ' = ' << var.arrayElemCount.to_s + ';')
        end
      }))

      bld.separate if Utils.instance.has_an_array?(cls)

      # Generate class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.name == 'id'
          bld.add('@Id')
          bld.add('@GeneratedValue(strategy=GenerationType.SEQUENCE)')
          bld.add(Utils.instance.getVarDec(var))
        else
          if !var.relation.nil?
            if var.relation.start_with? 'many-to-many'
              bld.add('@ManyToMany(cascade = CascadeType.ALL)')
            elsif var.relation.start_with? 'many-to-one'
              bld.add('@ManyToOne(cascade = CascadeType.ALL)')
            elsif var.relation.start_with? 'one-to-many'
              bld.add('@OneToMany(cascade = CascadeType.ALL)')
            elsif var.relation.start_with? 'one-to-one'
              bld.add('@OneToOne(cascade = CascadeType.ALL)')
            end
          end
          bld.add(Utils.instance.getVarDec(var))
        end
      }))

      bld.separate

      render_functions(cls, bld)
      render_header_var_group_getter_setters(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTEJava::ClassJpaEntity.new)
