require "x_c_t_e_plugin"

# Gets an edit model from a model
module XCTEDerived
  class DeriveListing < XCTEPlugin
    def initialize
      @name = "derive_listing"
      @category = XCTEPlugin::CAT_DERIVE
    end

    def get(editModel, derivedFrom, derivedFor)
      editModel.name = derivedFrom.name + " " + derivedFor
      editModel.data_node = derivedFrom.data_node
      editModel.description = derivedFrom.description

      editModel.varGroup = CodeStructure::CodeElemVarGroup.new
      editModel.xmlFileName = ""

      getEditModelRepresentationGrp(editModel, derivedFrom.varGroup, editModel.varGroup)

      return editModel
    end

    def getEditModelRepresentationGrp(editModel, vGroup, editGroup)
      for var in vGroup.vars
        if (var.selectFrom == nil)
          editGroup.vars.push(var)
        else
          if (!var.isList())
            selectVar = CodeStructure::CodeElemVariable.new(var.parentElem)
            selectClass = ClassModelManager.findVarClassByName(editModel, var)

            # If no model set class was found, use regular class
            if selectClass == nil
              selectClass = ClassModelManager.findVarClass(var)
            end

            if (selectClass == nil)
              Log.error("Unable to find edit model for var " + var.name)
            else
              selectIdVar = selectClass.model.getIdentityVar()

              selectVar.utype = selectIdVar.utype
              selectVar.vtype = selectIdVar.vtype
              selectVar.name = var.name + " id"
              selectVar.genGet = var.genGet
              selectVar.genSet = var.genSet
              selectVar.selectFrom = var.selectFrom
              selectVar.visibility = var.visibility

              editGroup.vars.push(selectVar)
            end
          end
        end
      end

      for grp in vGroup.varGroups
        newEditGroup = CodeStructure::CodeElemVarGroup.new
        getEditModelRepresentationGrp(editModel, grp, newEditGroup)
        editGroup.varGroups.push(newEditGroup)
      end
    end
  end
end

XCTEPlugin::registerModelPlugin(XCTEDerived::DeriveListing.new)
