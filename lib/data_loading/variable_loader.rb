##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "code_structure/code_elem_variable.rb"
require "code_structure/code_elem_build_var.rb"
require "rexml/document"
require "data_loading/attribute_loader"

module DataLoading
  class VariableLoader

    # Loads a variable from an XML variable node
    def self.loadVariableNode(varXML, parentElem, pComp)
      curVar = CodeStructure::CodeElemVariable.new(parentElem)
      curVar.data_node = varXML

      curVar.vtype = AttributeLoader.init().xml(varXML).names("type").get()
      curVar.utype = AttributeLoader.init().xml(varXML).names("utype").get()
      curVar.visibility = AttributeLoader.init().xml(varXML).names("visibility").default(curVar.visibility).get()
      curVar.passBy = AttributeLoader.init().xml(varXML).names("passby").default(curVar.passBy).get()
      AttributeLoader.init().xml(varXML).names("set").isTplAttrib().get(curVar)
      AttributeLoader.init().xml(varXML).names("tpl").isTplAttrib().get(curVar)

      curVar.init_vars = AttributeLoader.init().xml(varXML).names("init_vars").doInherit().get() == 'true'

      curVar.arrayElemCount = varXML.attributes["maxlen"].to_i
      curVar.isConst = varXML.attributes.get_attribute("const") != nil
      curVar.isStatic = varXML.attributes.get_attribute("static") != nil
      #curVar.isPointer = varXML.attributes.get_attribute("pointer") != nil || varXML.attributes.get_attribute("ptr") != nil
      curVar.isSharedPointer = varXML.attributes.get_attribute("sharedptr") != nil
      curVar.init = varXML.attributes["init"]
      curVar.namespace = NamespaceUtil.loadNamespaces(varXML, pComp)
      curVar.isVirtual = curVar.required = AttributeLoader.init().xml(varXML).names("virtual").doInherit().get == "true"
      curVar.nullable = curVar.required = AttributeLoader.init().xml(varXML).names("nullable").doInherit().get == "true"      
      curVar.identity = varXML.attributes["identity"]
      curVar.isPrimary = varXML.attributes["pkey"] == "true"
      curVar.name = varXML.attributes["name"]
      curVar.display_name = varXML.attributes["display"]
      curVar.selectFrom = varXML.attributes["select_from"]
      curVar.isOptions_list = (varXML.attributes["options"] == "true")
      curVar.relation = AttributeLoader.init().xml(varXML).names("rel").get
      curVar.storeIn = AttributeLoader.init().xml(varXML).names("store_in").get

      curVar.required = AttributeLoader.init().xml(varXML).names("required").default("false").doInherit().get == "true"
      curVar.readonly = AttributeLoader.init().xml(varXML).names("readonly").default("false").doInherit().get == "true"

      curVar.genGet = AttributeLoader.init().xml(varXML).names("genGet").default(curVar.genGet).doInherit().get == "true"
      curVar.genSet = AttributeLoader.init().xml(varXML).names("genSet").default(curVar.genSet).doInherit().get == "true"

      curVar.comment = varXML.attributes["comm"]
      curVar.defaultValue = AttributeLoader.init().xml(varXML).names("default").doInherit().get

      # puts "[ElemClass::loadVariable] loaded variable: " + curVar.name

      parentElem.add_var curVar
    end
  end
end
