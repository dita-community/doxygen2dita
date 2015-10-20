<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:local="urn:namespace:local-functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"

  exclude-result-prefixes="xs xd local relpath"
  version="2.0">
  
  <!-- ===============================================
       Local functions used by the Doxygen XML-to-DITA
       transform.
       =============================================== -->
  
  <!-- Given a Doxygen element, construct the corresponding
       relative topic URI.
       
       @param context Element to get the topic URI for
       @return The URI string. 
       
    -->
  <xsl:function name="local:getTopicUri" as="xs:string">
    <xsl:param name="context" as="element()"/>
    
    <!-- For <compound> elements, the @refid value functions as the path and filename -->
    <xsl:variable name="refID" as="xs:string"
      select="$context/@refid"
    />
    
    <xsl:variable name="result" as="xs:string"
      select="concat('topics/', $refID, '.dita')"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <!-- Construct the DITA key to use for a given
       element.
       
       @param context Element to get the key name for
       @return The key name
    -->
  <xsl:function name="local:getKey" as="xs:string">
    <xsl:param name="context" as="element()"/>
    
    <xsl:variable name="result" as="xs:string">
      <xsl:apply-templates select="$context" mode="local:getKey"/>
    </xsl:variable>
    
    <xsl:sequence select="$result"/>
  </xsl:function>

 <!-- Returns a value for use in @id attributes from
      the context element.
    -->
  <xsl:function name="local:getId" as="xs:string">
    <xsl:param name="context" as="element()"/>

    <xsl:variable name="result" as="xs:string"
      select="if ($context/@id) 
                 then replace($context/@id, '/', '_')
                 else generate-id($context)"
    />    
    <xsl:sequence select="$result"/>
  </xsl:function>

  <xsl:template mode="local:getKey" match="compound">
    <xsl:variable name="result" as="xs:string"
      select="translate(@refid, '/', '_')"
    />
    <xsl:sequence select="$result"/>
  </xsl:template>
  
  <xsl:template mode="local:getKey" match="compounddef">
    <xsl:variable name="result" as="xs:string"
      select="translate(@id, '/', '_')"
    />
    <xsl:sequence select="$result"/>
  </xsl:template>
  
  <xsl:template mode="local:getKey" match="programlisting">
    <xsl:variable name="result" as="xs:string"
      select="concat(local:getKey(..), '_', 'source')"
    />
    <xsl:sequence select="$result"/>
  </xsl:template>
  
  <xsl:template mode="local:getKey" match="ref | includes">
    <xsl:variable name="result" as="xs:string"
      select="translate(@refid, '/', '_')"
    />
    <xsl:sequence select="$result"/>
  </xsl:template>
  
  <xsl:template mode="local:getKey" match="*" priority="-1">
    <xsl:variable name="result" as="xs:string"
      select="generate-id(.)"
    />
    <xsl:sequence select="$result"/>
  </xsl:template>
  
  <xsl:function name="local:getLabelForKind" as="xs:string">
    <xsl:param name="kind" as="xs:string"/>
    <xsl:sequence select="local:getLabelForKind($kind, true())"/>
  </xsl:function>
  
  <xsl:function name="local:getLabelForKind" as="xs:string">
    <xsl:param name="kind" as="xs:string"/>
    <xsl:param name="plural" as="xs:boolean"/>
    
    <xsl:variable name="kinds" as="xs:string+"
      select="('class', 
               'struct', 
               'namespace', 
               'file', 
               'dir',
               'protected-attrib',
               'public-attrib',
               'public-func',
               'protected-func',
               'variable',
               'function',
               'union'
               )"
    />
    <xsl:variable name="labelsPlural" as="xs:string+"
      select="('Classes', 
               'Data Structures', 
               'Namespaces', 
               'Files', 
               'Directories',
               'Protected Attributes',
               'Data Fields',
               'Public Member Functions',
               'Protected Functions',
               'Properties',
               'Functions',
               'Unions'
               )"
    />
    <xsl:variable name="labelsSingular" as="xs:string+"
      select="('Class', 
               'Data Structure', 
               'Namespace', 
               'File', 
               'Directory',
               'Protected Attribute',
               'Data Field',
               'Public Function',
               'Protected Function',
               'Properties',
               'Function',
               'Union'
               )"
    />
    <xsl:variable name="p" as="xs:integer*"
      select="index-of($kinds, $kind)"
    />
    <xsl:variable name="label" as="xs:string?"
      select="if ($p) 
                 then 
                   if ($plural) then $labelsPlural[$p] else $labelsSingular[$p]
                 else ()"
    />
    <xsl:variable name="result"
      select="if ($label)
                 then $label
                 else concat('No label for kind ', $kind)"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="local:getIntroTextForKind" as="node()*">
    <xsl:param name="kind" as="xs:string"/>
    <xsl:variable name="kinds" as="xs:string+"
      select="('class', 
               'struct', 
               'namespace', 
               'file', 
               'dir',
               'protected-attrib',
               'public-func',
               'protected-func',
               'variable',
               'function'
               )"
    />
    <xsl:variable name="descriptors" as="xs:string+"
      select="('classes', 
               'data structures', 
               'namespaces', 
               'files', 
               'directories',
               'protected attributes',
               'public member functions',
               'protected functions',
               'properties',
               'functions'
               )"
    />
    <xsl:variable name="p" as="xs:integer*"
      select="index-of($kinds, $kind)"
    />
    <xsl:variable name="descriptor" as="xs:string?"
      select="if ($p) 
                 then $descriptors[$p]
                 else $kind"
    />
    <xsl:variable name="result" as="node()*"
    >
      <xsl:text>Here is a list of all </xsl:text>
      <xsl:value-of select="$descriptor"/>
      <xsl:text> with brief descriptions:</xsl:text>
    </xsl:variable>
    <xsl:sequence select="$result"/>
  </xsl:function>
  
</xsl:stylesheet>