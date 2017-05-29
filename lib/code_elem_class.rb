##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the class code structure
# read in from an xml file

require 'code_elem.rb' 
require 'code_elem_comment.rb'
require 'code_elem_format.rb'
require 'code_elem_function.rb'
require 'code_elem_include.rb'
require 'code_elem_parent.rb'
require 'code_elem_variable.rb'
require 'code_elem_var_group.rb'
require 'rexml/document'
require 'os'

module CodeStructure
  class CodeElemClass < CodeElem
    attr_accessor :classType, :name, :description, :includes, :baseClasses, 
      :functionSection, :case, :path, :coreClass, :groups, :namespaceList
    
    def initialize
      super()

      @elementId = CodeElem::ELEM_CLASS
      @classType = "standard"
      @name
      @path
      @case
      @description
      @includes = Array.new
      @baseClasses = Array.new
      @namespaces = Array.new
      @coreClass
      @groups = Array.new
      @functionSection = Array.new

      @path = ""
    end

    ##
    # Loads an XML class definition and stores it in this object
    def loadXMLClassFile(fName)
      file = File.new(fName)
      @path = fName
      xmlDoc = REXML::Document.new file

      if xmlDoc.root.attributes["classType"] != nil   
        @classType = xmlDoc.root.attributes["classType"]
      end
      
      @name = xmlDoc.root.attributes["name"]
      @namespaceList = xmlDoc.root.attributes["namespace"]

      if @namespaceList != nil
        @namespaceList = @namespaceList.split(',')

        @namespaceList.each { |nsItem|
          nsItem = nsItem.strip()
          puts nsItem
        }
      end
      
      @xmlElement = xmlDoc.root

      xmlDoc.elements.each("model/core_class") { |coreC|
        @coreClass = coreC.attributes["name"]
      }

      xmlDoc.elements.each("model/description") { |desc|
        @description = desc.text
      }

      xmlDoc.elements.each("model/parent") { |par|
        loadBaseClassNode(par)
      }

      xmlDoc.elements.each("model/include") { |inc|
        newInclude = CodeElemInclude.new
        if (inc.attributes["name"] != nil)
          newInclude.name = inc.attributes["name"]
		elsif (inc.attributes["lname"] != nil)		
          newInclude.name = inc.attributes["lname"]
		  newInclude.itype="<"
        end
        if (inc.attributes["path"] != nil)
          newInclude.path = inc.attributes["path"]
        end

        newInclude.xmlElement = inc
        @includes << newInclude
      }

#      xmlDoc.elements.each("model/VARIABLES") { |vars|
#        for varElem in vars.elements
#          if (varElem.name == "VARIABLE")
#            loadVariableNode(varElem, @varGroup.vars)
#          elsif (varElem.name == "COMMENT")
#            loadCommentNode(varElem, @variableSection)
#          elsif (varElem.name == "BR")
#            loadBRNode(varElem, @variableSection)
#          end
#        end
#      }

      xmlDoc.elements.each("model/var_group") { |vargXML|
        newVGroup = CodeElemVarGroup.new
        newVGroup.loadAttributes(vargXML)
        loadVarGroupNode(newVGroup, vargXML)
        @groups << newVGroup
      }
      
      xmlDoc.elements.each("model/functions") { |funXML|
        for varElemXML in funXML.elements
          if (varElemXML.name == "template_function")
            loadTemplateFunctionNode(varElemXML)
          elsif (varElemXML.name == "empty_function")
            loadEmptyFunctionNode(varElemXML)
          elsif (varElemXML.name == "comment")
            loadCommentNode(varElemXML, @functionSection)
          elsif (varElemXML.name == "br")
            loadBRNode(varElemXML, @functionSection)
          end
        end
      }
    end

    # Loads a parent from an XML parent node
    def loadBaseClassNode(parXML)
      newParent = CodeElemParent.new(
        parXML.attributes["name"],
        parXML.attributes["visibility"] )
      @baseClasses << newParent
       # puts "added parent node" + newParent.name
    end

    # Loads a variable from an XML variable node
    def loadVariableNode(varXML, parentElem)
      curVar = CodeElemVariable.new(parentElem)
      curVar.xmlElement = varXML

      curVar.name         = varXML.attributes["name"]
      curVar.vtype        = varXML.attributes["type"]
      curVar.visibility   = curVar.attribOrDefault("visibility", curVar.visibility)
      curVar.passBy       = curVar.attribOrDefault("passby", curVar.passBy)
      curVar.listType   = varXML.attributes["list"]
      curVar.arrayElemCount   = varXML.attributes["len"].to_i
      curVar.isConst      = varXML.attributes["const"]
      curVar.isStatic     = varXML.attributes["static"]
      curVar.isPointer    = varXML.attributes["pointer"]
      
      curVar.genGet       = self.findAttribute("genGet")
      curVar.genSet       = self.findAttribute("genSet")
      
      curVar.comment      = varXML.attributes["comm"]
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
        if (vgXML.attributes.has_key?("genGet") && !varElem.attributes.has_key?("genGet"))
            varElem.attributes["genGet"] = vgXML.attributes.has_key?("genGet")
        end      
        if (vgXML.attributes.has_key?("genSet") && !varElem.attributes.has_key?("genSet"))
            varElem.attributes["genSet"] = vgXML.attributes.has_key?("genSet")
        end      
        if (varElem.name.downcase == "variable" || varElem.name.downcase == "var" )
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

    # Loads a template function element from an XML template function node
    def loadTemplateFunctionNode(tmpFunXML)
      curFunction = CodeElemFunction.new
      curFunction.loadAttributes(tmpFunXML)
      curFunction.name = tmpFunXML.attributes["name"]
      curFunction.isTemplate = true
      curFunction.isInline = (tmpFunXML.attributes["inline"] == "true")
      @functionSection << curFunction       
    end
        
    # Loads a function element from an XML function node
    def loadEmptyFunctionNode(empFunXML)
      curFunction = CodeElemFunction.new
      curFunction.loadAttributes(empFunXML)
      curFunction.name = empFunXML.attributes["name"]
      curFunction.isInline = (empFunXML.attributes["inline"] == "true")
      
      if empFunXML.attributes["const"] != nil && empFunXML.attributes["const"].casecmp("true")
        curFunction.isConst = true
      end
      if empFunXML.attributes["static"] != nil && empFunXML.attributes["static"].casecmp("true")
        curFunction.isStatic = true
      end
      if empFunXML.attributes["visibility"] != nil
        curFunction.visibility = empFunXML.attributes["visibility"]
      end
      if empFunXML.attributes["virtual"] != nil && empFunXML.attributes["virtual"].casecmp("true")
        curFunction.isVirtual = true
      end
      
      for funElemXML in empFunXML.elements
        if funElemXML.name == "parameters"
          for paramXML in funElemXML.elements
            loadVariableNode(paramXML, curFunction.parameters)
          end
        elsif funElemXML.name == "return_variable"
          retVar = Array.new
          loadVariableNode(funElemXML, retVar)
          curFunction.returnValue = retVar[0]
        end
      end
      
      @functionSection << curFunction           
    end
    
    # Loads a comment from an XML comment node
    def loadCommentNode(parXML, section)
        comNode = CodeElemComment.new( parXML.attributes["text"] )
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
        CodeElemClass.getVarsFor(vGrp, nil, varArray);
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
    def self.getVarsFor(vGroup, cfg, vArray)
      for var in vGroup.vars
        vArray << var
      end

      for grp in vGroup.groups
        getVarsFor(grp, cfg, vArray)
      end

     # puts vArray.size
    end

    # Returns all variables in this class that match the cfg
    def getAllVarsFor(cfg, varArray)
      for vGrp in @groups
        CodeElemClass.getVarsFor(vGrp, cfg, varArray)
      end
    end
    
    def getNamespaceList(cfg, varArray)
      if @namespaceList != nil
        return @namespaceList.join('.')
      else
        return ''
      end
    end
  end
end
