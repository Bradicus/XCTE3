# XCTE3
XML Code Template Engine 3

The XML Code Template Engine is a Ruby script that reads in an XML file with a class
description then generates a class code skeleton in various languages. The code class skeleton 
can include templated functions of equality assignment, io based functions(must be custom
implimented), and more. It has a very simple plugin system allowing users to easly add 
their own plugins. Since the programming language is Ruby the code is cross platform. The 
program is similar to GUI popups in IDEs where the user inputs a class name and selects a 
few options then the IDE generates basic files based on that information. XCTE is 
different in that it can produce some functions procedurally generated from a template, 
it produces Doyxgen compatable comments(for some languages), can use plugins, and it is XML based.

Several example class template xml files are in the test/templates folder.

XCTE supports the following languages to various degrees:

* C++
* C#
* Php
* Java
* Javascript
* Ruby
* TSql

See license.txt for license information
