##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class is the base class for all code elements

class CodeElem
  attr_accessor :elementId, :xmlElement, :osInclude, :parentElem, :visibility,
                :name, :displayName, :description

  ELEM_MODEL = "class"
  ELEM_CLASS_GEN = "class_gen"
  ELEM_HEADER = "header"
  ELEM_LIBRARY = "library"
  ELEM_APPLICATION = "app"
  ELEM_BODY = "body"
  ELEM_BUILD_OPTION = "build_option"
  ELEM_BUILD_TYPE = "build_type"
  ELEM_COMMENT = "comment"
  ELEM_FORMAT = "format"
  ELEM_FUNCTION = "function"
  ELEM_INCLUDE = "include"
  ELEM_USE = "use"
  ELEM_PARENT = "parent"
  ELEM_VARIABLE = "variable"
  ELEM_VAR_GROUP = "variable_group"

  ELEM_PROJECT = "project"
  ELEM_PROJECT_COMPONENT_GROUP = "project_cg"
  ELEM_TEMPLATE_DIRECTORY = "templates"

  def initialize(parentElem = nil)
    @elementId

    @osInclude = Array.new   # What os's this node is processed on
    @langInclude = Array.new # What languages this node generates code in

    @xmlElement     # Points to the xml element a code element
                    # is read from, making it easier to add and use custom
                    # tags

    @visibility = "public"
    @parentElem = parentElem
  end

  # Loads attributes all code elements share
  def loadAttributes(nodeXML)
    @xmlElement = nodeXML

    if (nodeXML.attributes["lang_ignore"] != nil)
      ignoreLangs = nodeXML.attributes["lang_ignore"].split(",")
      for iLang in ignoreLangs
        @langInclude.delete(strip(iLang))
      end
    end

    if (nodeXML.attributes["lang_only"] != nil)
      ignoreLangs = nodeXML.attributes["lang_only"].split(",")
      @langInclude = Array.new
      for iLang in ignoreLangs
        @langInclude << strip(iLang)
      end
    end
  end

  # Find an attribute searching through parent elements if it doesn't exist
  # on this element
  def findAttribute(attribName)
    if @xmlElement.attributes[attribName] != nil
      return(@xmlElement.attributes[attribName])
    else
      if @parentElem != nil
        return(@parentElem.findAttribute(attribName))
      end
    end

    return nil
  end

  # Find an attribute searching through parent elements if it doesn't exist
  # on this element
  def findAttributeExists(attribName)
    if @xmlElement.attributes.get_attribute(attribName) != nil
      return true
    else
      if @parentElem != nil
        return(@parentElem.findAttributeExists(attribName))
      end
    end

    return false
  end

  def attribOrDefault(attribName, default)
    if @xmlElement.attributes[attribName] != nil
      return(@xmlElement.attributes[attribName])
    end

    return default
  end
end
