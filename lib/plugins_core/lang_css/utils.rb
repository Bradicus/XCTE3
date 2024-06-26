##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile"
require "utils_base"

module XCTECss
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("css")
    end

    # Get a parameter declaration for a method parameter
    def get_param_dec(var)
      pDec = String.new

      pDec << get_type_name(var.vtype)

      pDec << " " << var.name

      if var.arrayElemCount > 0
        pDec << "[]"
      end

      return pDec
    end

    # Returns variable declaration for the specified variable
    def get_var_dec(var)
      vDec = String.new
      typeName = String.new

      if var.isConst
        vDec << "const "
      end

      if var.isStatic
        vDec << "static "
      end

      vDec << get_styled_variable_name(var)
      vDec << ": " + get_type_name(var)

      if var.arrayElemCount.to_i > 0 && var.vtype != "String"
        vDec << "[" + get_size_const(var) << "]"
      end

      vDec << ";"

      if !var.comment.nil?
        vDec << "\t/** " << var.comment << " */"
      end

      return vDec
    end

    # Returns a size constant for the specified variable
    def get_size_const(var)
      return "ARRAYSZ_" << var.name.upcase
    end

    # Get a type name for a variable
    def get_type_name(var)
      typeName = get_single_item_type_name(var)

      if !var.listType.nil?
        typeName = "[]"
      end

      return typeName
    end

    def get_single_item_type_name(var)
      typeName = ""
      baseTypeName = get_base_type_name(var)

      if !var.templateType.nil?
        typeName = var.templateType + "<" + baseTypeName + ">"
      end

      if typeName.length == 0
        typeName = baseTypeName
      end

      return typeName
    end

    # Return the language type based on the generic type
    def get_base_type_name(var)
      nsPrefix = ""

      baseTypeName = ""
      if !var.vtype.nil?
        baseTypeName = @langProfile.get_type_name(var.vtype)
      else
        baseTypeName = CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end

      baseTypeName = nsPrefix + baseTypeName

      return baseTypeName
    end

    def get_list_type_name(listTypeName)
      return @langProfile.get_type_name(listTypeName)
    end

    # Get the extension for a file type
    def get_extension(eType)
      return @langProfile.get_extension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def get_comment(var)
      return "/* " << var.text << " */\n"
    end

    # Capitalizes the first letter of a string
    def get_capitalized_first(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      if str.length > 1
        newStr += str[1..str.length - 1]
      end

      return(newStr)
    end

    # process variable group
    def render_reactive_form_group(_cls, bld, vGroup, isDisabled)
      bld.same_line("this.fb.group({")
      bld.indent

      for var in vGroup.vars
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          if Utils.instance.is_primitive(var)
            if var.isList
              bld.add(Utils.instance.get_styled_variable_name(var) + ": [''],")
            else
              bld.add(Utils.instance.get_styled_variable_name(var) + ": this.fb.array(),")
            end
          else
            otherClass = ClassModelManager.findVarClass(var)

            if var.isList
              bld.add(Utils.instance.get_styled_variable_name(var) + ": ")
              if !otherClass.nil?
                for group in otherClass.model.groups
                  render_reactive_form_group(otherClass, bld, group, isDisabled)
                end
              else
                bld.same_line("[''],")
              end
            else
              bld.add(Utils.instance.get_styled_variable_name(var) + ": this.fb.array(),")
            end
          end
        end
        # for group in vGroup.varGroups
        #   process_var_group(cls, bld, group)
        # end
      end

      bld.unindent
      bld.add("}),")
    end

    def get_styled_url_name(name)
      return CodeNameStyling.getStyled(name, "DASH_LOWER")
    end
  end
end
