#
module XCTERuby
  class MethodLoad < XCTEPlugin
    def initialize
      @name = "method_load"
      @language = "ruby"
      @category = XCTEPlugin::CAT_METHOD
    end
    
    # Returns the code for the content for this function
    def get_definition(cls, bld, fun)
      # process class variables
      # Generate code for class variables
      eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
      if !var.isStatic   # Ignore static variables
        if Utils.instance.isPrimitive(var)
          if var.arrayElemCount.to_i > 0	# Array of primitives)
            bld.startBlock("for i in 0..@" << var.name << ".size")
            bld.add(var.name + "[i] = src" + cls.name + "[i]")
            bld.endBlock
          else
            bld.add(var.name + " = " + "src" + cls.name + "." + var.name)
          end
        else
          if var.arrayElemCount > 0	# Array of objects
            bld.startBlock("for i in 0..@" << var.name << ".size")
            bld.add(var.name << "[i] = src" << cls.name << "[i]")
            bld.endBlock
          else
            bld.add(var.name + " = " + "src" + cls.name + "." + var.name)
          end
        end
      end
      }))
    end
  end
end

XCTEPlugin::registerPlugin(XCTERuby::MethodLoad.new)
