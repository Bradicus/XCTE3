##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

module CodeStructure
  class CodeElemClassSpec < CodeElem
    attr_accessor :element_id, :model, :plug_name, :path, :namespace, :language, :includes, :uses, :actions, :gen_cfg, :functions,
            :base_classes, :interfaces, :injections, :interface_namespace, :interface_path, :test_namespace, :test_path, :template_params,
            :var_prefix, :pre_defs, :file_path, :standard_class, :standard_class_type, :custom_code, :data_class,
            :class_group_ref, :class_group_name, :variant, :feature_group
        
    def initialize(cls, model, parent_elem)
      super(CodeElemTypes::ELEM_CLASS_GEN, parent_elem)

      @model = model
      @plug_name = nil
      @path = ""
      @namespace = CodeElemNamespace.new
      @language = ""
      @includes = []
      @uses = []
      @actions = []
      @gen_cfg = nil
      @functions = []
      @base_classes = []
      @interfaces = []
      @injections = []
      @interface_namespace = CodeElemNamespace.new
      @interface_path = nil
      @test_namespace = CodeElemNamespace.new
      @test_path = nil
      @template_params = []
      @var_prefix = nil
      @pre_defs = []
      @file_path = nil
      @standard_class = nil
      @standard_class_type = nil
      @custom_code = nil
      @data_class = nil
      @class_group_ref = nil
      @class_group_name = nil
      @variant = nil
      @feature_group = nil
    end
    
    def addInclude(iPath, iName, iType = nil)
      iPath = String.new if iPath.nil?

      raise 'Include name cannot be nil' if iName.nil? || iName.length == 0

      curInc = nil

      for i in @includes
        curInc = i if i.path == iPath && i.name == iName
      end

      return unless curInc.nil?

      curInc = CodeElemInclude.new(iPath, iName, iType)
      @includes << curInc
    end

    def addUse(use, _forClass = nil)
      curUse = nil
      usNs = CodeElemNamespace.new(use)

      for i in @uses
        curUse = i if i.namespace.same?(usNs)
      end

      return unless curUse.nil?

      curUse = CodeElemUse.new(usNs)
      @uses << curUse
    end

    def addInjection(var)
      found = false
      for inj in @injections
        return true if inj.name == var.name && inj.getUType == var.getUType
      end

      @injections << var
    end

    def hasUsing(useName)
      for i in @uses
        return true if i.namespace == useName
      end

      return false
    end

    def get_u_name
      if !@name.nil? && @name.length > 0
        return @name 
      end

      return @model.name
    end

    def findVar(varName, varNs = nil)
      varFound = findVarInGroup(@model.varGroup, varName, varNs)
      return varFound if !varFound.nil?

      return nil
    end

    def findVarInGroup(vGroup, varName, varNs)
      for var in vGroup.vars
        return var if var.name == varName && (varNs.nil? || var.namespace.get('.') == varNs)
      end

      for grp in vGroup.varGroups
        varFound = findVarInGroup(grp, varName, varNs)
        return varFound if !varFound.nil?
      end

      return nil
    end

    def get_function(funName)      
      Utils.instance.each_fun(UtilsEachFunParams.new(cls, bld, lambda { |fun| 
        if fun.name == funName
          return fun
        end
      }));
    end
  end
end
