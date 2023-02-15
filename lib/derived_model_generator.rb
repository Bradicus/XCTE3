class DerivedModelGenerator
  def self.getEditModelRepresentation(editModel, derivedFrom, derivedFor)
    editModel.xmlElement = derivedFrom.xmlElement
    editModel.description = derivedFrom.description

    editModel.varGroup = CodeStructure::CodeElemVarGroup.new
    editModel.xmlFileName = ""

    getEditModelRepresentationGrp(derivedFrom.varGroup, editModel.varGroup)

    return editModel
  end

  def self.getEditModelRepresentationGrp(vGroup, editGroup)
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
          selectVar.genGet = var.genGet
          selectVar.genSet = var.genSet
          selectVar.selectFrom = var.selectFrom
          selectVar.visibility = var.visibility

          editGroup.vars.push(selectVar)
        else
          editGroup.vars.push(var)
        end
      end
    end

    for grp in vGroup.varGroups
      newEditGroup = CodeStructure::CodeElemVarGroup.new
      getEditModelRepresentationGrp(grp, newEditGroup)
      editGroup.varGroups.push(newEditGroup)
    end
  end
end
