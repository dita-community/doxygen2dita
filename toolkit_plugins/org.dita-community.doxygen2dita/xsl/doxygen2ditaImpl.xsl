<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
  <!-- =================================================================================
       Doxygen XML to DITA Transform
       
       This transform takes as input a Doxygen XML output index.xml file and generates
       from it a set of DITA maps and topics.
       
       This code is implemented as a DITA Open Toolkit plugin mostly to make it easy
       to access its dependencies and to make it easy run. It has no dependency
       on the normal DITA Open Toolkit preprocessing.
       
       Copyright (c) 2015 Oculus
       
       Authored by W. Eliot Kimber, ekimber@contrext.com
       
       ================================================================================= -->

  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/relpath_util.xsl"/>
  <xsl:import href="fallbackTemplates.xsl"/>
  <xsl:import href="generateKeydefs.xsl"/>
  <xsl:import href="generateTopicrefs.xsl"/>
  <xsl:import href="generateTopics.xsl"/>
  <xsl:import href="localFunctions.xsl"/>
  
  <xsl:output 
    doctype-public="-//OASIS//DTD DITA Map//EN" 
    doctype-system="map.dtd"
    indent="yes"
    />

  <xsl:output name="refTopic"
    doctype-public="-//OASIS//DTD DITA Reference//EN" 
    doctype-system="reference.dtd"
    indent="yes"
    />

  <xsl:output name="topic"
    doctype-public="-//OASIS//DTD DITA Topic//EN" 
    doctype-system="topic.dtd"
    indent="yes"
    />

  <!-- ============================
       Global variables
       ============================ -->
  
  <!-- The full set of compound kinds -->
  <xsl:variable name="compoundKinds" as="xs:string+"
    select="('page', 
             'file', 
             'dir', 
             'class', 
             'struct', 
             'union', 
             'interface',
             'protocol',
             'category',
             'exception',
             'group',
             'example',
             'namespace')"
  />
  <!-- The set of compound kinds to reflect in the
       DITA map. 
       
       This list determines the <compound> elements
       within the index.xml file that are used
       to produce the DITA map, that is, the top-level
       categories.       
       
    -->
  <xsl:variable name="compoundKindsToUse" as="xs:string+"
    select="('page', 
             'file',
             'struct'
             )"
  />
  

  <xsl:template match="/">
    <!-- Input should be doxygen-generated index.xml file 
    
         The direct output is the root map.
    -->
    
<!--    <xsl:message> + [INFO] Doxygen XML-to-DITA tranform...</xsl:message>-->
<!--    <xsl:message> + [INFO] Output directory=<xsl:value-of select="$outdir"/></xsl:message>-->
    
    <xsl:apply-templates/>
    
  </xsl:template>
  
  <xsl:template match="doxygenindex">
    <map>
      <title><xsl:value-of select="$mapTitle"/></title>
      <topicgroup><xsl:comment> Key definitions </xsl:comment>
        <xsl:apply-templates mode="generateKeyDefinitions" select="."/>
      </topicgroup>
      <topicgroup><xsl:comment> Publication body </xsl:comment>
        <xsl:apply-templates mode="generateTopicrefs" select="."/>
      </topicgroup>
    </map>
    <!-- Now generate the result topics -->
    <xsl:apply-templates mode="generateTopics" select="."/>
  </xsl:template>
  
</xsl:stylesheet>