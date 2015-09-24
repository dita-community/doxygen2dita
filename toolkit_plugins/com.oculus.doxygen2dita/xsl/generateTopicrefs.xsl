<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:local="urn:namespace:local-functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"

  exclude-result-prefixes="xs xd local relpath"
  version="2.0">
  
  <xsl:template mode="generateTopicrefs" match="doxygenindex">
    <xsl:variable name="context" as="element()" select="."/>
    <!-- Topics are grouped by @kind value -->
    <!-- @kind values in the order that they should be reflected in
         the result map. In particular, pages should come first.
         
         See index.xsd produced by the Doxygen XML generation process.
      -->
    <xsl:for-each select="$compoundKindsToUse">
      <xsl:variable name="kind" as="xs:string" select="."/>
      <xsl:variable name="topicURI" as="xs:string" select="concat('topics/', $kind, '.dita')"/>
      <xsl:variable name="resultURI" as="xs:string"
        select="relpath:newFile($outdir, $topicURI)"
      />
      <!-- Pages represent top-level HTML pages, so they don't get 
           organized under a kind group.
           
        -->
      <xsl:choose>
        <!-- Pages are arbitrary content -->
        <xsl:when test="$kind = 'page'">
          <xsl:apply-templates
            mode="#current"
            select="$context/compound[@kind = $kind]"
          />          
        </xsl:when>
        <xsl:otherwise>
          <xsl:result-document href="{$resultURI}" format="topic">
            <topic id="{$kind}">
              <title>
                <xsl:value-of 
                select="local:getLabelForKind($kind)"
              />
              </title>
              <body>
                <p><xsl:sequence select="local:getIntroTextForKind($kind)"/></p>
              </body>
            </topic>
          </xsl:result-document>
          <topicref href="{$topicURI}">
            <xsl:apply-templates
              mode="#current"
              select="$context/compound[@kind = $kind]"
            />
          </topicref>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="generateTopicrefs" match="compound">
    <xsl:variable name="topicURI" as="xs:string"
      select="local:getTopicUri(.)"
    />
    <xsl:variable name="resultURI" as="xs:string"
      select="relpath:newFile($outdir, $topicURI)"
    />
    <xsl:variable name="keyName" as="xs:string"
      select="local:getKey(.)"
    />
    <topicref keys="{$keyName}"
        href="{$topicURI}"
    >
      <xsl:apply-templates mode="#current"/>
    </topicref>
  </xsl:template>

</xsl:stylesheet>