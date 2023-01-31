##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "code_elem_variable.rb"
require "code_elem_build_var.rb"
require "rexml/document"

module DataProcessing
  class VariableLoader

    # Loads a variable from an XML variable node
    def self.loadVariableNode(varXML, parentElem, pComponent)
      curVar = CodeStructure::CodeElemVariable.new(parentElem)
      curVar.xmlElement = varXML

      curVar.vtype = varXML.attributes["type"]
      curVar.utype = varXML.attributes["utype"]
      curVar.visibility = AttributeUtil.loadInheritableAttribute(varXML, "visibility", pComponent, curVar.visibility)
      curVar.passBy = curVar.attribOrDefault("passby", curVar.passBy)
      if AttributeUtil.hasAttribute(varXML, "set")
        AttributeUtil.loadTemplateAttribute(curVar, varXML, "set", pComponent)
      end
      if AttributeUtil.hasAttribute(varXML, "tpl")
        AttributeUtil.loadTemplateAttribute(curVar, varXML, "tpl", pComponent)
      end
      curVar.arrayElemCount = varXML.attributes["maxlen"].to_i
      curVar.isConst = varXML.attributes.get_attribute("const") != nil
      curVar.isStatic = varXML.attributes.get_attribute("static") != nil
      #curVar.isPointer = varXML.attributes.get_attribute("pointer") != nil || varXML.attributes.get_attribute("ptr") != nil
      curVar.isSharedPointer = varXML.attributes.get_attribute("sharedptr") != nil
      curVar.init = varXML.attributes["init"]
      curVar.namespace = NamespaceUtil.loadNamespaces(varXML, pComponent)
      curVar.isVirtual = curVar.findAttributeExists("virtual")
      curVar.nullable = curVar.findAttributeExists("nullable")
      curVar.identity = varXML.attributes["identity"]
      curVar.isPrimary = varXML.attributes["pkey"] == "true"
      curVar.name = varXML.attributes["name"]
      curVar.displayName = varXML.attributes["display"]
      curVar.selectFrom = varXML.attributes["select_from"]
      curVar.isOptionsList = (varXML.attributes["options"] == "true")
      curVar.relation = AttributeUtil.loadAttribute(varXML, "rel", pComponent)
      curVar.storeIn = AttributeUtil.loadAttribute(varXML, "store_in", pComponent)

      curVar.required = AttributeUtil.loadInheritableAttribute(varXML, "required", pComponent, "false") == "true"
      curVar.readonly = AttributeUtil.loadInheritableAttribute(varXML, "readonly", pComponent, "false") == "true"

      if (varXML.attributes.get_attribute("attribs"))
        AttributeUtil.loadAttribNode(curVar, varXML.attributes["attribs"])
      end

      curVar.genGet = AttributeUtil.loadInheritableAttribute(varXML, "genGet", pComponent, curVar.genGet) == "true"
      curVar.genSet = AttributeUtil.loadInheritableAttribute(varXML, "genSet", pComponent, curVar.genSet) == "true"

      curVar.comment = varXML.attributes["comm"]
      curVar.defaultValue = varXML.attributes["default"]

      # puts "[ElemClass::loadVariable] loaded variable: " << curVar.name

      parentElem.vars << curVar
    end
  end
end
