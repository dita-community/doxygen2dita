<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
  <!-- ========================================
       Fallback templates to handle unhandled
       elements in each mode.
       ======================================== -->
  
  <xsl:template match="*" priority="-1">
    <xsl:message> - [WARN] Unhandled element in <xsl:value-of select="document-uri(root(.))"/></xsl:message>
    <xsl:call-template name="reportUnhandledElement"/>
  </xsl:template>
  
  <xsl:template name="reportUnhandledElement">
    <xsl:param name="modeName" as="xs:string" select="'#default'"/>
    <xsl:message> - [WARN] <xsl:value-of select="$modeName"/>: Unhandled element <xsl:value-of select="concat(name(..), '/', name(.))"/><xsl:if test="@kind">, kind="<xsl:value-of select="@kind"/>"</xsl:if></xsl:message>
  </xsl:template>
  
  <xsl:template match="*" mode="mapTitle" priority="-1">
    <xsl:call-template name="reportUnhandledElement">
      <xsl:with-param name="modeName" select="'mapTitle'"/>
    </xsl:call-template>  
  </xsl:template>
  
  <xsl:template match="*" mode="generateMap" priority="-1">
    <xsl:call-template name="reportUnhandledElement">
      <xsl:with-param name="modeName" select="'generateMap'"/>
    </xsl:call-template>  
  </xsl:template>
  
  <xsl:template match="*" mode="generateTopics" priority="-1">
    <xsl:call-template name="reportUnhandledElement">
      <xsl:with-param name="modeName" select="'generateTopics'"/>
    </xsl:call-template>  
  </xsl:template>
  
  <xsl:template match="*" mode="fullTopics" priority="-1">
    <xsl:call-template name="reportUnhandledElement">
      <xsl:with-param name="modeName" select="'fullTopics'"/>
    </xsl:call-template>  
  </xsl:template>
  
  <xsl:template match="*" mode="summary" priority="-1">
    <xsl:call-template name="reportUnhandledElement">
      <xsl:with-param name="modeName" select="'summary'"/>
    </xsl:call-template>  
  </xsl:template>
  
  <xsl:template match="*" mode="generateKeyDefinitions" priority="-1">
    <xsl:call-template name="reportUnhandledElement">
      <xsl:with-param name="modeName" select="'generateKeyDefinitions'"/>
    </xsl:call-template>  
  </xsl:template>
  
  <!-- Suppress text by default -->
  <xsl:template match="text()" 
                priority="-1"
                mode="mapTitle 
                      generateMap 
                      generateTopicrefs
                      generateKeyDefinitions"
  />
  
  
  
</xsl:stylesheet>