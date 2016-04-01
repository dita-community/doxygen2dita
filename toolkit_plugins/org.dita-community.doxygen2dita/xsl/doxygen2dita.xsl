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
       
       FIXME: Make this into a DITA OT template with appropriate extension points to 
       enable extension via other plugins.
       
       Copyright (c) 2015, 2016 DITA Community
       
       Authored by W. Eliot Kimber, ekimber@contrext.com
       
       ================================================================================= -->

  <xsl:import href="doxygen2ditaImpl.xsl"/>

  <!-- Output directory to write result files to. -->
  <xsl:param name="outdir" as="xs:string"/> 
  <xsl:param name="mapTitle" as="xs:string" select="'API Documentation'"/>
  
  
  
</xsl:stylesheet>