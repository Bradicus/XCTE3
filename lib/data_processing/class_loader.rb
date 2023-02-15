##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads class information form an XML node

require "code_elem_project.rb"
require "code_elem_build_var.rb"
require "data_processing/variable_loader"
require "data_processing/attribute_util"
require "data_processing/namespace_util"
require "data_processing/class_ref_loader"
require "rexml/document"

module DataProcessing
  class ClassLoader

    # Loads a class from an xml node
    def self.loadClass(pComponent, genC, genCXml)
      genC.plugName = AttributeUtil.loadInheritableAttribute(genCXml, "type", pComponent)
      genC.className = genCXml.attributes["name"]
      genC.namespace = NamespaceUtil.loadNamespaces(genCXml, pComponent)
      genC.interfaceNamespace = CodeStructure::CodeElemNamespace.new(genCXml.attributes["interface_namespace"])
      genC.interfacePath = genCXml.attributes["interface_path"]
      genC.testNamespace = CodeStructure::CodeElemNamespace.new(genCXml.attributes["test_namespace"])
      genC.testPath = AttributeUtil.loadAttribute(genCXml, "test_path", pComponent)
      genC.language = genCXml.attributes["language"]
      genC.path = AttributeUtil.loadAttribute(genCXml, "path", pComponent)
      genC.varPrefix = AttributeUtil.loadAttribute(genCXml, "var_prefix", pComponent)

      # Add base namespace to class namespace lists
      if (pComponent.namespace.nsList.size() > 0)
        genC.namespace.nsList = pComponent.namespace.nsList + genC.namespace.nsList
      end

      #genC.name

      genCXml.elements.each("base_class") { |bcXml|
        baseClass = CodeStructure::CodeElemClassGen.new(CodeStructure::CodeElemModel.new, nil, pComponent, false)
        baseClass.name = bcXml.attributes["name"]
        baseClass.namespace = NamespaceUtil.loadNamespaces(bcXml, pComponent)

        bcXml.elements.each("tpl_param") { |tplXml|
          tplParam = CodeStructure::CodeElemClassGen.new(CodeStructure::CodeElemModel.new, nil, pComponent, false)
          tplParam.name = tplXml.attributes["name"]
          baseClass.templateParams << tplParam
        }

        genC.baseClasses << baseClass
      }

      genCXml.elements.each("pre_def") { |pdXml|
        genC.preDefs << pdXml.attributes["name"]
      }

      genCXml.elements.each("data_class") { |dcXml|
        genC.dataClass = ClassRefLoader.loadClassRef(dcXml, genCXml, pComponent)
      }

      genCXml.elements.each("interface") { |ifXml|
        intf = CodeStructure::CodeElemClassGen.new(CodeStructure::CodeElemModel.new, nil, pComponent, false)
        intf.name = ifXml.attributes["name"]
        intf.namespace = NamespaceUtil.loadNamespaces(ifXml, pComponent)
        genC.interfaces << intf
      }

      genCXml.elements.each("function") { |funXml|
        newFun = CodeStructure::CodeElemFunction.new(genC)
        loadTemplateFunctionNode(genC, newFun, funXml)
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

      #   # Also include higher level includes from model
      #   model.xmlElement.elements.each("include") { |gIncXml|
      #     iName = gIncXml.attributes["name"]
      #     iLName = gIncXml.attributes["lname"]

      #     if gIncXml.attributes["path"] != nil
      #       iPath = gIncXml.attributes["path"]
      #     else
      #       iPath = String.new
      #     end

      #     if (gIncXml.attributes["name"] != nil)
      #       genC.addInclude(iPath, iName, '"')
      #     else
      #       genC.addInclude(iPath, iLName, "<")
      #     end
      #   }

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
      #   model.xmlElement.elements.each("use") { |gUseXml|
      #     genC.addUse(gUseXml.attributes["name"])
      #   }

      # Load any auto includes for this class...
      # Load any auto uses for this class...

      #puts "Loaded clss note with function count " + genC.functions.length.to_s
    end

    # Loads a template function element from an XML template function node
    def self.loadTemplateFunctionNode(genC, fun, tmpFunXML)
      fun.loadAttributes(tmpFunXML)
      fun.name = tmpFunXML.attributes["name"]
      #puts "Loading function: " + fun.name
      fun.isTemplate = true
      fun.isInline = (tmpFunXML.attributes["inline"] == "true")

      varArray = Array.new
      tmpFunXML.elements.each("var_ref") { |refXml|
        ref = genC.findVar(refXml.attributes["name"])
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
            VariableLoader.loadVariableNode(paramXML, newFun.parameters, pComponent)
          end
        elsif funElemXML.name == "return_variable"
          retVar = Array.new
          VariableLoader.loadVariableNode(funElemXML, funXml)
          newFun.returnValue = parentElem.vars[0]
        end
      end
    end

    def self.loadTemplateAttribute(var, varXml, attribName, language)
      tpls = AttributeUtil.loadAttribute(varXml, attribName, language)

      tplItems = tpls.split(",")
      for tplItem in tplItems
        tplC = CodeStructure::CodeElemTemplate.new(tplItem.strip())
        var.templates.push(tplC)
      end
    end

    # Loads a comment from an XML comment node
    def self.loadCommentNode(parXML, section)
      comNode = CodeElemComment.new(parXML.attributes["text"])
      comNode.AttributeUtil.loadAttributes(parXML)
      section << comNode
    end

    # Loads a br format element from an XML br node
    def self.loadBRNode(brXML, section)
      brk = CodeElemFormat.new("\n")
      brk.AttributeUtil.loadAttributes(brXML)
      section << brk
    end

    def self.loadList(str, separator)
      return str.split(separator).map!(&:trim)
    end
  end
end
