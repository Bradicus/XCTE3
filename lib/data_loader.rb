require "code_elem_var_group"
require "code_elem_function"
require "code_elem_model"
require "code_elem_class_gen"
require "code_elem_variable"
require "classes"

class DataLoader

  ##
  # Loads an XML class definition and stores it in this object
  def self.loadXMLClassFile(model, fName, isStatic)
    file = File.new(fName)
    model.xmlFileName = fName

    xmlString = file.read
    xmlDoc = REXML::Document.new xmlString

    model.name = xmlDoc.root.attributes["name"]

    model.xmlElement = xmlDoc.root

    xmlDoc.root.elements.each("description") { |desc|
      model.description = desc.text
    }

    xmlDoc.root.elements.each("var_group") { |vargXML|
      puts "loading var group"
      newVGroup = CodeStructure::CodeElemVarGroup.new
      newVGroup.loadAttributes(vargXML)
      loadVarGroupNode(newVGroup, vargXML)
      model.groups << newVGroup
    }

    xmlDoc.root.elements.each("gen_class") { |genCXML|
      cls = CodeStructure::CodeElemClassGen.new(model, model, isStatic)
      loadClassNode(cls, genCXML, model)
      cls.model = model
      cls.xmlElement = genCXML
      Classes.list << cls
      model.classes << cls

      if cls.interfaceNamespace != nil
        intf = CodeStructure::CodeElemClassGen.new(cls, model, isStatic)
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
        intf = CodeStructure::CodeElemClassGen.new(cls, model, isStatic)
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
  def self.loadVariableNode(varXML, parentElem)
    curVar = CodeStructure::CodeElemVariable.new(parentElem)
    curVar.xmlElement = varXML

    curVar.vtype = varXML.attributes["type"]
    curVar.utype = varXML.attributes["utype"]
    curVar.visibility = curVar.attribOrDefault("visibility", curVar.visibility)
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

    curVar.genGet = curVar.findAttributeExists("genGet")
    curVar.genSet = curVar.findAttributeExists("genSet")

    curVar.comment = varXML.attributes["comm"]
    curVar.defaultValue = varXML.attributes["default"]

    # puts "[ElemClass::loadVariable] loaded variable: " << curVar.name

    parentElem.vars << curVar
  end

  # Loads a group node from an XML template vargroup node
  def self.loadVarGroupNode(vgNode, vgXML)
    if (vgXML.attributes["name"] != nil)
      vgNode.name = vgXML.attributes["name"]
    end

    puts "[ElemClass::loadVarGroupNode] loading var node "

    for varElem in vgXML.elements
      if (varElem.name.downcase == "variable" || varElem.name.downcase == "var")
        loadVariableNode(varElem, vgNode)
      elsif (varElem.name == "var_group")
        newVG = CodeStructure::CodeElemVarGroup.new
        newVG.loadAttributes(varElem)
        loadVarGroupNode(newVG, varElem)
        vgNode.groups << newVG
      elsif (varElem.name == "comment")
        loadCommentNode(varElem, vgNode.vars)
      elsif (varElem.name == "br")
        loadBRNode(varElem, vgNode.vars)
      end
    end
  end

  def self.loadClassNode(genC, genCXml, model)
    genC.ctype = genCXml.attributes["type"]
    if (genCXml.attributes["namespace"] != nil)
      genC.namespaceList = genCXml.attributes["namespace"].split(".")
    end
    genC.interfaceNamespace = genCXml.attributes["interface_namespace"]
    genC.interfacePath = genCXml.attributes["interface_path"]
    genC.testNamespace = genCXml.attributes["test_namespace"]
    genC.testPath = genCXml.attributes["test_path"]
    genC.language = genCXml.attributes["language"]
    genC.path = genCXml.attributes["path"]
    genC.varPrefix = genCXml.attributes["var_prefix"]

    #genC.name

    genCXml.elements.each("base_class") { |bcXml|
      baseClass = CodeStructure::CodeElemClassGen.new(CodeStructure::CodeElemModel.new, nil, false)
      baseClass.name = bcXml.attributes["name"]
      if bcXml.attributes["namespace"] != nil
        baseClass.namespaceList = bcXml.attributes["namespace"].split(".")
      end

      bcXml.elements.each("tpl_param") { |tplXml|
        tplParam = CodeStructure::CodeElemClassGen.new(CodeStructure::CodeElemModel.new, nil, false)
        tplParam.name = tplXml.attributes["name"]
        baseClass.templateParams << tplParam
      }

      genC.baseClasses << baseClass
    }

    genCXml.elements.each("interface") { |ifXml|
      intf = CodeStructure::CodeElemClassGen.new(CodeStructure::CodeElemModel.new, nil, false)
      intf.name = ifXml.attributes["name"]
      if ifXml.attributes["namespace"] != nil
        intf.namespaceList = ifXml.attributes["namespace"].split(".")
      end
      genC.interfaces << intf
    }

    genCXml.elements.each("function") { |funXml|
      newFun = CodeStructure::CodeElemFunction.new(genC)
      loadTemplateFunctionNode(newFun, funXml)
      genC.functions << newFun
    }

    genCXml.elements.each("empty_function") { |funXml|
      newFun = CodeStructure::CodeElemFunction.new(genC)
      loadEmptyFunctionNode(newFun, funXml)
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
    puts "Loading function: " + fun.name
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
  def self.loadEmptyFunctionNode(newFun, funXml)
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
          loadVariableNode(paramXML, newFun.parameters)
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
