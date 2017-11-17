##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the class code structure
# read in from an xml file

require 'code_elem.rb'
require 'code_elem_class_gen.rb'
require 'code_elem_comment.rb'
require 'code_elem_format.rb'
require 'code_elem_function.rb'
require 'code_elem_include.rb'
require 'code_elem_parent.rb'
require 'code_elem_variable.rb'
require 'code_elem_var_group.rb'
require 'rexml/document'

module CodeStructure
  class CodeElemModel < CodeElem
    attr_accessor :classes, :name, :description,
                  :case, :groups, :xmlFileName

    def initialize
      super()

      @elementId = CodeElem::ELEM_MODEL
      @classes = Array.new
      @name
      @case
      @description
      @groups = Array.new
      @xmlFileName = ""
    end

    ##
    # Loads an XML class definition and stores it in this object
    def loadXMLClassFile(fName, isStatic)
      file = File.new(fName)
      @xmlFileName = fName

      xmlString = file.read
      xmlDoc = REXML::Document.new xmlString

      @name = xmlDoc.root.attributes["name"]

      @xmlElement = xmlDoc.root

      xmlDoc.root.elements.each("description") {|desc|
        @description = desc.text
      }

      xmlDoc.root.elements.each("var_group") {|vargXML|
        puts "loading var group"
        newVGroup = CodeElemVarGroup.new
        newVGroup.loadAttributes(vargXML)
        loadVarGroupNode(newVGroup, vargXML)
        @groups << newVGroup
      }

      xmlDoc.root.elements.each("gen_class") {|genCXML|
        genClass = CodeElemClassGen.new(self, self, isStatic)
        loadClassNode(genClass, genCXML, self)
        genClass.model = self
        @classes << genClass

        if genClass.interfaceNamespace != nil
          intf = CodeElemClassGen.new(genClass, self, isStatic)
          intf.namespaceList = genClass.interfaceNamespace.split('.')
          intf.path = genClass.interfacePath
          intf.functions = genClass.functions
          intf.language = genClass.language
          intf.ctype = 'interface'
          intf.parentElem = genClass
          intf.model = self
          @classes << intf
        end

        if genClass.testNamespace != nil
          intf = CodeElemClassGen.new(genClass, self, isStatic)
          intf.namespaceList = genClass.testNamespace.split('.')
          intf.path = genClass.testPath
          intf.language = genClass.language
          intf.ctype = 'test_engine'
          intf.parentElem = genClass
          intf.model = self
          @classes << intf
        end

        #puts "Loaded class node with function count " + genClass.functions.length.to_s
        #puts "classes count " + @classes.length.to_s
      }
    end

    # Loads a variable from an XML variable node
    def loadVariableNode(varXML, parentElem)
      curVar = CodeElemVariable.new(parentElem)
      curVar.xmlElement = varXML

      curVar.vtype = varXML.attributes["type"]
      curVar.utype = varXML.attributes["utype"]
      curVar.visibility = curVar.attribOrDefault("visibility", curVar.visibility)
      curVar.passBy = curVar.attribOrDefault("passby", curVar.passBy)
      curVar.listType = varXML.attributes["collection"]
      curVar.arrayElemCount = varXML.attributes["maxlen"].to_i
      curVar.isConst = varXML.attributes["const"]
      curVar.isStatic = varXML.attributes["static"]
      curVar.isPointer = varXML.attributes["pointer"]
      curVar.isVirtual = curVar.findAttribute("virtual")
      curVar.nullable = curVar.findAttribute("nullable")
      curVar.identity = varXML.attributes["identity"]
      curVar.isPrimary = varXML.attributes["pkey"] == 'true'
      curVar.name = varXML.attributes["name"]

      curVar.genGet = curVar.findAttribute("genGet")
      curVar.genSet = curVar.findAttribute("genSet")

      curVar.comment = varXML.attributes["comm"]
      curVar.defaultValue = varXML.attributes["default"]

      # puts "[ElemClass::loadVariable] loaded variable: " << curVar.name

      parentElem.vars << curVar
    end

    # Loads a group node from an XML template vargroup node
    def loadVarGroupNode(vgNode, vgXML)
      if (vgXML.attributes["name"] != nil)
        vgNode.name = vgXML.attributes["name"]
      end

      puts "[ElemClass::loadVarGroupNode] loading var node "

      for varElem in vgXML.elements
        if (varElem.name.downcase == "variable" || varElem.name.downcase == "var")
          loadVariableNode(varElem, vgNode)
        elsif (varElem.name == "var_group")
          newVG = CodeElemVarGroup.new
          loadVarGroupNode(subvgXML, newVG)
          vgNode.groups << newVG
        elsif (varElem.name == "comment")
          loadCommentNode(varElem, vgNode.vars)
        elsif (varElem.name == "br")
          loadBRNode(varElem, vgNode.vars)
        end
      end


      #        vgXML.each("VARIABLE") { |varXML|
      #          newVar = CodeElemVariable.new
      #          loadVariableNode(varXML, newVar)
      #          vgNode.vars << newVar
      #        }

    end

    def loadClassNode(genC, genCXml, model)
      genC.ctype = genCXml.attributes["type"]
      genC.namespaceList = genCXml.attributes["namespace"].split('.')
      genC.interfaceNamespace = genCXml.attributes["interface_namespace"]
      genC.interfacePath = genCXml.attributes["interface_path"]
      genC.testNamespace = genCXml.attributes["test_namespace"]
      genC.testPath = genCXml.attributes["test_path"]
      genC.language = genCXml.attributes["language"]
      genC.path = genCXml.attributes["path"]
      genC.varPrefix = genCXml.attributes["var_prefix"]

      genC.name = name

      if (genCXml.attributes["base_class"] != nil)
        baseClass = CodeElemClassGen.new(CodeElemModel.new, nil, false)
        baseClass.name = genCXml.attributes["base_class"]
        genC.baseClasses << baseClass
      end

      genCXml.elements.each("function") {|funXml|
        newFun = CodeElemFunction.new(genC)
        loadTemplateFunctionNode(newFun, funXml)
        genC.functions << newFun
      }

      genCXml.elements.each("empty_function") {|funXml|
        newFun = CodeElemFunction.new(genC)
        loadEmptyFunctionNode(newFun, funXml)
        newFun.isTemplate = false
        genC.functions << newFun
      }

      genCXml.elements.each("include") {|incXml|
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
      self.xmlElement.elements.each("include") {|gIncXml|
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
      genCXml.elements.each("use") {|useXml|
        if (useXml.attributes["name"] != nil)
          genC.addUse(useXml.attributes["name"])
        end
      }

      # Load any auto includes for this class...
      # Load any auto uses for this class...

      #puts "Loaded class note with function count " + genC.functions.length.to_s
    end

    # Loads a template function element from an XML template function node
    def loadTemplateFunctionNode(fun, tmpFunXML)
      fun.loadAttributes(tmpFunXML)
      fun.name = tmpFunXML.attributes["name"]
      puts "Loading function: " + fun.name
      fun.isTemplate = true
      fun.isInline = (tmpFunXML.attributes["inline"] == "true")

      varArray = Array.new
      getAllVarsFor(varArray)
      tmpFunXML.elements.each("var_ref") {|refXml|
        fun.variableReferences << varArray.find { |var| var.name == refXml.attributes["name"] }
      }
    end

    # Loads a function element from an XML function node
    def loadEmptyFunctionNode(newFun, funXml)
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
          loadVariableNode(funElemXML, retVar)
          newFun.returnValue = retVar[0]
        end
      end
    end

    # Loads a comment from an XML comment node
    def loadCommentNode(parXML, section)
      comNode = CodeElemComment.new(parXML.attributes["text"])
      comNode.loadAttributes(parXML)
      section << comNode
    end

    # Loads a br format element from an XML br node
    def loadBRNode(brXML, section)
      brk = CodeElemFormat.new("\n")
      brk.loadAttributes(brXML)
      section << brk
    end

    # Returns whether or not this class has an array variable
    def hasAnArray
      varArray = Array.new

      for vGrp in groups
        CodeElemModel.getVarsFor(vGrp, varArray)
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount.to_i > 0
          return true
        end
      end

      return false
    end

    # Returns whether or not this class has an variable of this type
    def hasVariableType(vt)
      variableSection = Array.new
      getAllVarsFor(nil, variableSection)
      for var in variableSection
        if var.elementId == CodeElem::ELEM_VARIABLE && var.vtype == vt
          return true
        end
      end

      return false
    end

    def getObjFileName
      lowName = @name
      lowName = lowName.downcase

      if (@case != nil && lowName != nil)
        return(lowName + ".o");
      else
        return(@name + ".o");
      end
    end

    def getCppFileName
      lowName = @name
      lowName = lowName.downcase

      if (@case != nil && lowName != nil)
        return(lowName + ".cpp");
      else
        return(@name + ".cpp");
      end
    end

    def getHeaderFileName
      lowName = @name
      lowName = lowName.downcase

      if (@case != nil && lowName != nil)
        return(lowName + ".h");
      else
        return(@name + ".h");
      end
    end

    # Returns all variables in this class that match the cfg
    def self.getVarsFor(vGroup, vArray)
      for var in vGroup.vars
        vArray << var
      end

      for grp in vGroup.groups
        getVarsFor(grp, vArray)
      end

      # puts vArray.size
    end

    # Returns all variables in this class that match the cfg
    def getAllVarsFor(varArray)
      for vGroup in @groups
        CodeElemModel.getVarsFor(vGroup, varArray)
      end
    end

    def getScreenVars(varArray, screenFunction)
      for vGroup in @groups
        getScreenGroup(vGroup, varArray, screenFunction)
      end
    end

    # Screen variables based on pass functoin
    def getScreenGroup(vGroup, varArray, screenFunction)
      for var in vGroup.vars
        if screenFunction.call(var)
          varArray << var
        end
      end

      for grp in vGroup.groups
        getScreenGroup(grp, varArray, screenFunction)
      end
    end

    # Returns add primary keys from vGroup
    def getPrimaryKeyVars(varArray)
      getScreenVars(varArray, lambda {|var| var.isPrimary == true })
    end
    
    # Returns add primary keys from vGroup
    def getNonIdentityVars(varArray)
      getScreenVars(varArray, lambda {|var| var.identity == nil })
    end
    
    # Returns add primary keys from vGroup
    def getIdentityVar()
      varArray = Array.new
      getScreenVars(varArray, lambda {|var| var.identity != nil })

      if (varArray.length > 0)
        return(varArray[0])
      end

      return nil
    end

    # Returns namespaces separated by .
    def getNamespaceList(cfg, varArray)
      if @namespaceList != nil
        return @namespaceList.join('.')
      else
        return ''
      end
    end

    def findClassFunction(classPlugName, funPlugName)
      cs = @classes # for debugging
      for c in @classes
        if (c.ctype == classPlugName)
          for fun in c.functions
            if fun.name == funPlugName
              return fun
            end
          end
          
          # if we found the class but not the function, we can return nil here
          return nil
        end
      end

      return nil
    end
  end
end
