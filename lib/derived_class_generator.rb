class DerivedClassGenerator
  def self.getEditClassRepresentation(cls)
    editModel = CodeStructure::CodeElemModel.new()
    editModel.name = cls.model.name
    editModel.description = cls.model.description
    editModel.classes = cls.model.classes
    editModel.varGroup = CodeStructure::CodeElemVarGroup.new
    editModel.xmlFileName = ""

    getEditClassRepresentationGrp(cls, cls.model.varGroup, editModel.varGroup)

    editCls = CodeStructure::CodeElemClassGen.new(
      cls.parentElem, editModel, false
    )

    editCls.xmlElement = cls.xmlElement
    editCls.genCfg = cls.genCfg
    editCls.path = cls.path
    editCls.namespace = cls.namespace
    editCls.interfaceNamespace = cls.interfaceNamespace

    return editCls
  end

  def self.getEditClassRepresentationGrp(cls, vGroup, editGroup)
    for var in vGroup.vars
      if (var.selectFrom == nil)
        editGroup.vars.push(var)
      else
        if (!var.isList())
          selectVar = CodeStructure::CodeElemVariable.new(var.parentElem)
          selectClass = Classes.findVarClass(var)
          selectIdVar = selectClass.model.getIdentityVar()
          selectVar.utype = selectIdVar.utype
          selectVar.vtype = selectIdVar.vtype
          selectVar.name = var.name + " id"

          editGroup.vars.push(selectVar)
        else
          editGroup.vars.push(var)
        end
      end
    end

    for grp in vGroup.varGroups
      newEditGroup = CodeStructure::CodeElemVarGroup.new
      getEditClassRepresentationGrp(cls, grp, newEditGroup)
      editGroup.varGroups.push(newEditGroup)
    end
  end
end
