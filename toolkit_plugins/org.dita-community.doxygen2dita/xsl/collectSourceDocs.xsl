<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- ===============================================================
       Doxygen to DITA
       
       Collect Source Docs
       
       Manages constructing a list of all the source docs ultimately
       referenced from the initial index.xml file.
       
       This list of docs is used to look up element IDs using a normal
       key table by applying the table lookup to each document in turn.
       
       =============================================================== -->

  <xsl:template name="collect-source-docs" as="document-node()*">
    <xsl:variable name="baseList" as="document-node()*">
      <xsl:apply-templates mode="collect-source-docs"
        select="compound"
      />      
    </xsl:variable>
    <!-- Use union operator remove duplicates -->
    <xsl:sequence select="$baseList | ()"/>
  </xsl:template>

  <xsl:template mode="collect-source-docs" 
    match="compound | innerfile | innerclass " 
    >
    <xsl:variable name="sourceURI" as="xs:string"
      select="concat(@refid, '.xml')"
    />
    <xsl:variable name="sourceDoc" as="document-node()?"
      select="document($sourceURI, .)"
    />
    <xsl:sequence select="$sourceDoc"/>
    <xsl:apply-templates mode="#current" select="$sourceDoc/*"/>
  </xsl:template>
  
  <xsl:template mode="collect-source-docs" match="*" priority="-1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="collect-source-docs" match="text()"/>
  
</xsl:stylesheet>