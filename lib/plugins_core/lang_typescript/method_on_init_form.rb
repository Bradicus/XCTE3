module XCTETypescript
  class MethodOnInitForm < XCTEPlugin
    def initialize
      @name = 'method_on_init_form'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns the code for the content for this function
    def render_function(cls, bld)
      # process class variables
      for group in cls.model.groups
        process_var_group(cls, bld, group)
      end
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      for var in vGroup.vars
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          if !var.isStatic # Ignore static variables
            if Utils.instance.is_primitive(var)
              if var.arrayElemCount.to_i > 0 # Array of primitives)
                bld.start_block('for i in 0..@' << var.name + '.size')
                bld.add(var.name + '[i] = src' + codeClass.name + '[i]')
                bld.end_block
              else
                bld.add(var.name + ' = ' + 'src' + codeClass.name + '.' + var.name)
              end
            elsif var.arrayElemCount > 0
              bld.start_block('for i in 0..@' + var.name + '.size')
              bld.add(var.name << '[i] = src' + codeClass.name + '[i]')
              bld.end_block # Array of objects
            else
              bld.add(var.name + ' = ' + 'src' + codeClass.name + '.' + var.name)
            end
          end
        elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
          bld.add(XCTECpp::Utils.get_comment(var))
        elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
          bld.add(var.formatText)
        end
      end
      for group in vGroup.varGroups
        process_var_group(cls, bld, group)
      end
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::MethodOnInitForm.new)
