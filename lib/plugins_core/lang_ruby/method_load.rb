module XCTERuby
  class MethodLoad < XCTEPlugin
    def initialize
      @name = 'method_load'
      @language = 'ruby'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns the code for the content for this function
    def get_definition(cls, bld, _fun)
      # process class variables
      # Generate code for class variables
      each_var(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.isStatic # Ignore static variables
          if Utils.instance.is_primitive(var)
            if var.arrayElemCount.to_i > 0	# Array of primitives)
              bld.start_block('for i in 0..@' << var.name << '.size')
              bld.add(var.name + '[i] = src' + cls.name + '[i]')
              bld.end_block
            else
              bld.add(var.name + ' = ' + 'src' + cls.name + '.' + var.name)
            end
          elsif var.arrayElemCount > 0
            bld.start_block('for i in 0..@' << var.name << '.size')
            bld.add(var.name << '[i] = src' << cls.name << '[i]')
            bld.end_block	# Array of objects
          else
            bld.add(var.name + ' = ' + 'src' + cls.name + '.' + var.name)
          end
        end
      }))
    end
  end
end

XCTEPlugin.registerPlugin(XCTERuby::MethodLoad.new)
