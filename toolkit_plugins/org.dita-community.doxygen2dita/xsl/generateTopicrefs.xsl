<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:local="urn:namespace:local-functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"

  exclude-result-prefixes="xs xd local relpath"
  version="2.0">
  
  <xsl:template mode="generateTopicrefs" match="doxygenindex">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="context" as="element()" select="."/>
    <!-- Topics are grouped by @kind value -->
    <!-- @kind values in the order that they should be reflected in
         the result map. In particular, pages should come first.
         
         See index.xsd produced by the Doxygen XML generation process.
      -->
    <xsl:for-each select="$compoundKindsToUse">
      <xsl:variable name="kind" as="xs:string" select="."/>
      <xsl:variable name="kindsToMatch" as="xs:string+"
        select="if ($kind = 'struct') 
                   then ($kind, 'union') 
                   else ($kind)"
      />
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
          >
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates>          
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
          <topicref href="{$topicURI}" outputclass="compoundset {.}">
            <xsl:apply-templates
              mode="#current"
              select="$context/compound[@kind = $kindsToMatch]"
            >
              <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </topicref>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="generateAncilaryTopicrefs" match="doxygenindex | doxygen">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="generateTopicrefs" match="compound">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="topicURI" as="xs:string"
      select="local:getTopicUri(.)"
    />
    <xsl:variable name="resultURI" as="xs:string"
      select="relpath:newFile($outdir, $topicURI)"
    />
    <xsl:variable name="keyName" as="xs:string"
      select="local:getKey(.)"
    />
    <xsl:variable name="sourceURI" as="xs:string"
         select="concat(@refid, '.xml')"
    />
    <xsl:variable name="sourceDoc" as="document-node()?"
      select="document($sourceURI, .)"
    />
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generateTopicrefs: compound (<xsl:value-of select="@kind"/>): sourceURI="<xsl:value-of select="$sourceURI"/>"</xsl:message>
      <xsl:message> + [DEBUG] generateTopicrefs: compound: isEmptyDoc()=<xsl:value-of select="local:isEmptyDoc($sourceDoc)"/>"</xsl:message>
    </xsl:if>
    
    <xsl:variable name="skipEmptyDirFile" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="@kind = ('dir')">
          <xsl:variable name="files" as="node()*">
            <xsl:apply-templates select="$sourceDoc/*/compounddef/innerfile">
              <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:sequence select="not($files)"/>          
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="local:isEmptyDoc($sourceDoc) or $skipEmptyDirFile">
        <xsl:message> + [INFO] generateTopicrefs: Source document <xsl:value-of select="$sourceURI"/> has no content, skipping.</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <topicref keys="{$keyName}"  outputclass="{name(.)} {@kind}"
            href="{$topicURI}"
        >
          <xsl:apply-templates mode="#current">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates>
        </topicref>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="generateAncilaryTopicrefs" match="compound">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="topicURI" as="xs:string"
      select="local:getTopicUri(.)"
    />
    <xsl:variable name="resultURI" as="xs:string"
      select="relpath:newFile($outdir, $topicURI)"
    />
    <xsl:variable name="keyName" as="xs:string"
      select="local:getKey(.)"
    />
    <xsl:variable name="sourceURI" as="xs:string"
         select="concat(@refid, '.xml')"
    />
    <xsl:variable name="sourceDoc" as="document-node()?"
      select="document($sourceURI, .)"
    />
    <xsl:apply-templates mode="#current" select="$sourceDoc/*">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="generateAncilaryTopicrefs" match="compounddef[@kind = ('file')]" priority="10">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generateAncilaryTopicrefs: compounddef kind=file</xsl:message>
      <xsl:message> + [DEBUG] generateAncilaryTopicrefs: data-structures key: <xsl:value-of select="local:getKey(., 'data-structures')"/></xsl:message>
      <xsl:message> + [DEBUG] generateAncilaryTopicrefs: topic URI: <xsl:value-of select="local:getTopicUri(.)"/></xsl:message>
      <xsl:message> + [DEBUG] generateAncilaryTopicrefs: topic ID: <xsl:value-of select="local:getId(., 'data-structures')"/></xsl:message>
    </xsl:if>

    <!-- File compounddefs have a synthesized data structures topic that contains
         sections for each struct definition.
      -->
    <xsl:if test="innerclass">
      <topicref keys="{local:getKey(., 'data-structures')}" 
        href="{local:getTopicUri(.)}#{local:getId(., 'data-structures')}" 
        toc="no"
      />
    </xsl:if>
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="generateAncilaryTopicrefs" match="compounddef">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generateAncilaryTopicrefs: compounddef default template: kind="<xsl:value-of select="@kind"/>"</xsl:message>
    </xsl:if>
    
    <xsl:variable name="doDebug" as="xs:boolean" select="false()"/>
    
    <xsl:choose>
      <xsl:when test="local:isEmptyDoc(root(.))">
        <xsl:message> + [INFO] generateAncilaryTopicrefs: Ignoring empty document "<xsl:value-of select="compoundname"/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

  <xsl:template mode="generateAncilaryTopicrefs" match="programlisting">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="topicURI" as="xs:string"
      select="concat('topics/', local:getKey(.), '.dita')"
    />
    <xsl:variable name="resultURI" as="xs:string"
      select="relpath:newFile($outdir, $topicURI)"
    />
    <xsl:choose>
      <xsl:when test="local:isEmptyDoc(root(.))">
        <xsl:message> + [INFO] generateAncilaryTopicrefs (programlisting): Doc is empty, not generating a program listing or topic reference.</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:result-document href="{$resultURI}" format="topic">
          <xsl:apply-templates select="." mode="fullTopics">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates>
        </xsl:result-document>
        <topicref toc="no" keys="{local:getKey(.)}" href="{$topicURI}"  outputclass="{name(.)} {@kind}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="generateAncilaryTopicrefs" match="sectiondef">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="generateAncilaryTopicrefs" priority="10"
    match="compounddef[@kind = ('union')]/sectiondef[@kind = ('public-attrib')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- public-attrib sectiondefs don't make topics within union compounddefs -->
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="generateAncilaryTopicrefs" priority="10"
    match="sectiondef[@kind = ('user-defined')][memberdef[@kind = 'enum']]"
    >
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- This sectiondef doesn't generate a topic as all the enum definitions
         collected under a generated topic with the ID "enum".         
      -->
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="generateAncilaryTopicrefs" 
      match="sectiondef[@kind = ('define', 'typedef', 'public-attrib', 'user-defined', 'enum')]"
    >
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="topicID" as="xs:string" select="local:getId(.)"/>
    <xsl:variable name="topicURI" as="xs:string"
      select="concat('topics/', local:getKey(ancestor::compounddef), '.dita',
      '#',$topicID)"
    />

    <topicref  toc="no" keys="{local:getKey(.)}" href="{$topicURI}" outputclass="{name(.)} {@kind}">
      <xsl:comment><xsl:value-of select="header"/></xsl:comment>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </topicref>
    
  </xsl:template>

  <xsl:template mode="generateAncilaryTopicrefs" match="text()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>    
  </xsl:template>
  
  <xsl:template mode="generateAncilaryTopicrefs" match="memberdef[@kind = ('define', 'enum', 'typedef', 'function')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- memberdefs are chunked within their containing compounddef's 
         topic.
      -->
    <xsl:variable name="topicID" as="xs:string" select="local:getId(.)"/>
    <xsl:variable name="topicURI" as="xs:string"
      select="concat('topics/', local:getKey(ancestor::compounddef), '.dita',
                     '#',$topicID)"
    />
    <xsl:variable name="resultURI" as="xs:string"
      select="relpath:newFile($outdir, $topicURI)"
    />
    <xsl:variable name="hasDetailedDesc" as="xs:boolean"
      select="not(matches(normalize-space(detaileddescription), '^\s*$'))"
    />
    <xsl:variable name="isEnumWithDetails" as="xs:boolean"
      select="local:isEnumWithDetails(.)"
    />
    <!-- Only elements that have detailed descriptions will become topics.
      -->
    <xsl:choose>
      <xsl:when test="$hasDetailedDesc or $isEnumWithDetails">
        <topicref toc="no" keys="{local:getKey(.)}" href="{$topicURI}" outputclass="{name(.)} {@kind}"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- No topic -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="generateAncilaryTopicrefs" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- Suppress by default as most elements do not generate ancilary topics -->
  </xsl:template>

</xsl:stylesheet>