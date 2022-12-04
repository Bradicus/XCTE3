#
module XCTETypescript
  class MethodOnInitForm < XCTEPlugin
    def initialize
      @name = "method_on_init_form"
      @language = "typescript"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld)
      # process class variables
      for group in cls.model.groups
        process_var_group(cls, bld, group)
      end
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !var.isStatic # Ignore static variables
            if Utils.instance.isPrimitive(var)
              if var.arrayElemCount.to_i > 0 # Array of primitives)
                bld.startBlock("for i in 0..@" << var.name << ".size")
                bld.add(var.name + "[i] = src" + codeClass.name + "[i]")
                bld.endBlock
              else
                bld.add(var.name + " = " + "src" + codeClass.name + "." + var.name)
              end
            else
              if var.arrayElemCount > 0 # Array of objects
                bld.startBlock("for i in 0..@" << var.name << ".size")
                bld.add(var.name << "[i] = src" << codeClass.name << "[i]")
                bld.endBlock
              else
                bld.add(var.name + " = " + "src" + codeClass.name + "." + var.name)
              end
            end
          end
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.add(XCTECpp::Utils::getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
      end
      for group in vGroup.groups
        process_var_group(cls, bld, group)
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::MethodOnInitForm.new)
