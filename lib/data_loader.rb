require "code_elem_var_group"
require "code_elem_function"
require "code_elem_model"
require "code_elem_class_gen"
require "code_elem_variable"
require "classes"

class DataLoader

  ##
  # Loads an XML class definition and stores it in this object
  def self.loadXMLClassFile(model, fName, pComponent)
    file = File.new(fName)
    model.xmlFileName = fName
    model.lastModified = file.mtime
    xmlString = file.read
    xmlDoc = REXML::Document.new xmlString
    depthStack = Array.new

    model.name = xmlDoc.root.attributes["name"]

    model.xmlElement = xmlDoc.root

    xmlDoc.root.elements.each("description") { |desc|
      model.description = desc.text
    }

    xmlDoc.root.elements.each("var_group") { |vargXML|
      #puts "loading var group"
      newVGroup = CodeStructure::CodeElemVarGroup.new
      newVGroup.loadAttributes(vargXML)
      loadVarGroupNode(newVGroup, vargXML, pComponent)
      model.groups << newVGroup
    }

    xmlDoc.root.elements.each("gen_class") { |genCXML|
      cls = CodeStructure::CodeElemClassGen.new(model, model, true)
      loadClassNode(cls, genCXML, model, pComponent)
      cls.model = model
      cls.xmlElement = genCXML
      Classes.list << cls
      model.classes << cls

      if cls.interfaceNamespace != nil
        intf = CodeStructure::CodeElemClassGen.new(cls, model, true)
        intf.namespaceList = cls.interfaceNamespace.split(".")
        intf.path = cls.interfacePath
        intf.functions = cls.functions
        intf.language = cls.language
        intf.ctype = "interface"
        intf.parentElem = cls
        intf.model = model
        Classes.list << intf
        model.classes << cls
      end

      if cls.testNamespace != nil
        intf = CodeStructure::CodeElemClassGen.new(cls, model, true)
        intf.namespaceList = cls.testNamespace.split(".")
        intf.path = cls.testPath
        intf.language = cls.language
        intf.ctype = "test_engine"
        intf.parentElem = cls
        intf.model = model
        Classes.list << intf
        model.classes << cls
      end

      #puts "Loaded clss node with function count " + cls.functions.length.to_s
      #puts "classes count " + Classes.list.length.to_s
    }
  end

  # Loads a variable from an XML variable node
  def self.loadVariableNode(varXML, parentElem, pComponent)
    curVar = CodeStructure::CodeElemVariable.new(parentElem)
    curVar.xmlElement = varXML

    curVar.vtype = varXML.attributes["type"]
    curVar.utype = varXML.attributes["utype"]
    curVar.visibility = loadAttribute(varXML, "visibility", pComponent.language, curVar.visibility)
    curVar.passBy = curVar.attribOrDefault("passby", curVar.passBy)
    if (varXML.attributes.get_attribute("collection") != nil)
      curVar.listType = varXML.attributes["collection"]
    elsif (varXML.attributes.get_attribute("set") != nil)
      curVar.listType = varXML.attributes["set"]
    elsif (varXML.attributes.get_attribute("tpl") != nil)
      curVar.templateType = varXML.attributes["tpl"]
    end
    curVar.arrayElemCount = varXML.attributes["maxlen"].to_i
    curVar.isConst = varXML.attributes.get_attribute("const") != nil
    curVar.isStatic = varXML.attributes.get_attribute("static") != nil
    curVar.isPointer = varXML.attributes.get_attribute("pointer") != nil || varXML.attributes.get_attribute("ptr") != nil
    curVar.isSharedPointer = varXML.attributes.get_attribute("sharedptr") != nil
    curVar.init = varXML.attributes["init"]
    curVar.namespace = varXML.attributes["ns"]
    curVar.isVirtual = curVar.findAttributeExists("virtual")
    curVar.nullable = curVar.findAttributeExists("nullable")
    curVar.identity = varXML.attributes["identity"]
    curVar.isPrimary = varXML.attributes["pkey"] == "true"
    curVar.name = varXML.attributes["name"]
    curVar.displayName = varXML.attributes["display"]

    curVar.genGet = loadAttribute(varXML, "genGet", pComponent.language, curVar.genGet) == "true"
    curVar.genSet = loadAttribute(varXML, "genSet", pComponent.language, curVar.genSet) == "true"

    curVar.comment = varXML.attributes["comm"]
    curVar.defaultValue = varXML.attributes["default"]

    # puts "[ElemClass::loadVariable] loaded variable: " << curVar.name

    parentElem.vars << curVar
  end

  # Loads a group node from an XML template vargroup node
  def self.loadVarGroupNode(vgNode, vgXML, pComponent)
    if (vgXML.attributes["name"] != nil)
      vgNode.name = vgXML.attributes["name"]
    end

    #puts "[ElemClass::loadVarGroupNode] loading var node "

    for varElem in vgXML.elements
      if (varElem.name.downcase == "variable" || varElem.name.downcase == "var")
        loadVariableNode(varElem, vgNode, pComponent)
      elsif (varElem.name == "var_group")
        newVG = CodeStructure::CodeElemVarGroup.new
        newVG.loadAttributes(varElem)
        loadVarGroupNode(newVG, varElem, pComponent)
        vgNode.groups << newVG
      elsif (varElem.name == "comment")
        loadCommentNode(varElem, vgNode.vars)
      elsif (varElem.name == "br")
        loadBRNode(varElem, vgNode.vars)
      end
    end
  end

  def self.loadClassNode(genC, genCXml, model, pComponent)
    genC.ctype = loadAttribute(genCXml, "type", pComponent.language)
    genC.className = genCXml.attributes["name"]
    genC.namespaceList = loadNamespaces(genCXml, pComponent)
    genC.interfaceNamespace = genCXml.attributes["interface_namespace"]
    genC.interfacePath = genCXml.attributes["interface_path"]
    genC.testNamespace = genCXml.attributes["test_namespace"]
    genC.testPath = loadAttribute(genCXml, "test_path", pComponent.language)
    genC.language = genCXml.attributes["language"]
    genC.path = loadAttribute(genCXml, "path", pComponent.language)
    genC.varPrefix = loadAttribute(genCXml, "var_prefix", pComponent.language)

    # Add base namespace to class namespace lists
    if (pComponent.namespaceList.size() > 0)
      genC.namespaceList = pComponent.namespaceList + genC.namespaceList
    end

    #genC.name

    genCXml.elements.each("base_class") { |bcXml|
      baseClass = CodeStructure::CodeElemClassGen.new(CodeStructure::CodeElemModel.new, nil, false)
      baseClass.name = bcXml.attributes["name"]
      baseClass.namespaceList = loadNamespaces(bcXml, pComponent)

      bcXml.elements.each("tpl_param") { |tplXml|
        tplParam = CodeStructure::CodeElemClassGen.new(CodeStructure::CodeElemModel.new, nil, false)
        tplParam.name = tplXml.attributes["name"]
        baseClass.templateParams << tplParam
      }

      genC.baseClasses << baseClass
    }

    genCXml.elements.each("pre_def") { |pdXml|
      genC.preDefs << pdXml.attributes["name"]
    }

    genCXml.elements.each("interface") { |ifXml|
      intf = CodeStructure::CodeElemClassGen.new(CodeStructure::CodeElemModel.new, nil, false)
      intf.name = ifXml.attributes["name"]
      intf.namespaceList = loadNamespaces(ifXml, pComponent)
      genC.interfaces << intf
    }

    genCXml.elements.each("function") { |funXml|
      newFun = CodeStructure::CodeElemFunction.new(genC)
      loadTemplateFunctionNode(newFun, funXml)
      genC.functions << newFun
    }

    genCXml.elements.each("empty_function") { |funXml|
      newFun = CodeStructure::CodeElemFunction.new(genC)
      loadEmptyFunctionNode(newFun, funXml, pComponent)
      newFun.isTemplate = false
      genC.functions << newFun
    }

    genCXml.elements.each("include") { |incXml|
      if incXml.attributes["path"] != nil
        iPath = incXml.attributes["path"]
      else
        iPath = String.new
      end

      if (incXml.attributes["name"] != nil)
        genC.addInclude(iPath, incXml.attributes["name"], '"')
      else
        genC.addInclude(iPath, incXml.attributes["lname"], "<")
      end
    }

    # Also include higher level includes from model
    model.xmlElement.elements.each("include") { |gIncXml|
      iName = gIncXml.attributes["name"]
      iLName = gIncXml.attributes["lname"]

      if gIncXml.attributes["path"] != nil
        iPath = gIncXml.attributes["path"]
      else
        iPath = String.new
      end

      if (gIncXml.attributes["name"] != nil)
        genC.addInclude(iPath, iName, '"')
      else
        genC.addInclude(iPath, iLName, "<")
      end
    }

    # Load uses
    genCXml.elements.each("use") { |useXml|
      if (useXml.attributes["name"] != nil)
        genC.addUse(useXml.attributes["name"])
      end
    }

    genCXml.elements.each("use-" + pComponent.language) { |useXml|
      if (useXml.attributes["name"] != nil)
        genC.addUse(useXml.attributes["name"])
      end
    }

    # Load uses from higher level
    model.xmlElement.elements.each("use") { |gUseXml|
      genC.addUse(gUseXml.attributes["name"])
    }

    # Load any auto includes for this class...
    # Load any auto uses for this class...

    #puts "Loaded clss note with function count " + genC.functions.length.to_s
  end

  # Loads a template function element from an XML template function node
  def self.loadTemplateFunctionNode(fun, tmpFunXML)
    fun.loadAttributes(tmpFunXML)
    fun.name = tmpFunXML.attributes["name"]
    #puts "Loading function: " + fun.name
    fun.isTemplate = true
    fun.isInline = (tmpFunXML.attributes["inline"] == "true")

    varArray = Array.new
    tmpFunXML.elements.each("var_ref") { |refXml|
      ref = varArray.find { |var| var.name == refXml.attributes["name"] }
      if ref
        fun.variableReferences << ref
      end
    }
  end

  # Loads a function element from an XML function node
  def self.loadEmptyFunctionNode(newFun, funXml, pComponent)
    newFun.loadAttributes(funXml)
    newFun.name = funXml.attributes["name"]
    newFun.isInline = (funXml.attributes["inline"] == "true")

    if funXml.attributes["const"] != nil && funXml.attributes["const"].casecmp("true")
      newFun.isConst = true
    end
    if funXml.attributes["static"] != nil && funXml.attributes["static"].casecmp("true")
      newFun.isStatic = true
    end
    if funXml.attributes["visibility"] != nil
      newFun.visibility = funXml.attributes["visibility"]
    end
    if funXml.attributes["virtual"] != nil && funXml.attributes["virtual"].casecmp("true")
      newFun.isVirtual = true
    end

    for funElemXML in funXml.elements
      if funElemXML.name == "parameters"
        newFun.parameters.loadAttributes(funElemXML)
        for paramXML in funElemXML.elements
          loadVariableNode(paramXML, newFun.parameters, pComponent)
        end
      elsif funElemXML.name == "return_variable"
        retVar = Array.new
        loadVariableNode(funElemXML, funXml)
        newFun.returnValue = parentElem.vars[0]
      end
    end
  end

  # Loads a comment from an XML comment node
  def self.loadCommentNode(parXML, section)
    comNode = CodeElemComment.new(parXML.attributes["text"])
    comNode.loadAttributes(parXML)
    section << comNode
  end

  # Load a list of namespaces on a node
  def self.loadNamespaces(xml, pComponent)
    return loadAttributeArray(xml, Array["ns", "namespace"], pComponent.language, ".")
  end

  def self.loadAttribute(xml, atrNames, language, default = nil)
    if !atrNames.kind_of?(Array)
      atrNames = Array[atrNames]
    end

    # Try load from parent first
    if (xml.parent != nil)
      for atrName in atrNames
        atr = xml.parent.attributes[atrName + "-" + language]
        if atr != nil
          return atr
        end
        atr = xml.parent.attributes[atrName]
        if atr != nil
          return atr
        end
      end
    end

    for atrName in atrNames
      atr = xml.attributes[atrName + "-" + language]
      if atr != nil
        return atr
      end
      atr = xml.attributes[atrName]
      if atr != nil
        return atr
      end
    end

    return default
  end

  def self.loadAttributeArray(xml, atrNames, language, separator)
    atr = loadAttribute(xml, atrNames, language)
    if atr != nil
      return atr.split(separator)
    end

    return Array.new
  end

  # Loads a br format element from an XML br node
  def self.loadBRNode(brXML, section)
    brk = CodeElemFormat.new("\n")
    brk.loadAttributes(brXML)
    section << brk
  end

  def self.loadList(str, separator)
    return str.split(separator).map!(&:trim)
  end
end
