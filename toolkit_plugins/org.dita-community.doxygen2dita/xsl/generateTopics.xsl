<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:local="urn:namespace:local-functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"

  exclude-result-prefixes="xs xd local relpath"
  version="2.0">
  
  <!-- ==========================================================
       Doxygen XML to DITA 
       
       Mode generateTopics
       
       Generates DITA topics for each of the top-level compound
       components (files, classes, datatypes, etc.)
       
       Initial context element is the root doxygenindex element
       in the index.xml file.
       
       ========================================================== -->
  
  <xsl:preserve-space elements="codeblock"/>
  
  <xsl:key name="elemsByID" match="*[@id]" use="@id"/>
  
  <xsl:template mode="generateTopics" match="doxygenindex">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template mode="generateTopics" match="compound">
    <xsl:variable name="topicURI" as="xs:string"
      select="local:getTopicUri(.)"
    />
    <xsl:variable name="resultURI" as="xs:string"
      select="relpath:newFile($outdir, $topicURI)"
    />
    
    <!-- The @refid value is the path to the corresponding XML
          file for the compound object, minus the .xml
          extension.
      -->
    <xsl:variable name="sourceURI" as="xs:string"
         select="concat(@refid, '.xml')"
    />
    <xsl:variable name="sourceDoc" as="document-node()?"
      select="document($sourceURI, .)"
    />
    <xsl:variable name="sourceDocBodyText"

    >
      <xsl:apply-templates mode="getBodyText" select="$sourceDoc/*"/>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="matches($sourceDocBodyText, '^\s*$')">
        <xsl:message> + [INFO] Source doc "<xsl:value-of select="$sourceURI"/>" has no text, skipping.</xsl:message>
      </xsl:when>
      <xsl:when test="@kind = ('page')">
        <xsl:result-document href="{$resultURI}" format="topic">
          <xsl:apply-templates select="$sourceDoc"/>
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
<!--        <xsl:message> + [INFO] Generating topic "<xsl:value-of select="$topicURI"/>"...</xsl:message>-->
        <xsl:result-document href="{$resultURI}" format="refTopic">
          <xsl:apply-templates select="$sourceDoc"/>
        </xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="getBodyText" match="*">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="getBodyText" match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template mode="getBodyText" match="compoundname" priority="10">
    <!-- Suppress -->
  </xsl:template>
  
  <xsl:template match="doxygen">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="compounddef[@kind = ('page')]" priority="10">
    <topic id="{local:getId(.)}">
      <xsl:apply-templates select="title"/>
      <xsl:apply-templates mode="shortDesc" select="."/>
      <body>
        <xsl:apply-templates mode="#current" 
            select="node() except (title)"
        />
      </body>
    </topic>
  </xsl:template>

  <xsl:template match="compounddef">
    <reference id="{local:getId(.)}" outputclass="{@kind}">
      <xsl:apply-templates mode="topicTitle" select="."/>
      <xsl:apply-templates mode="shortDesc" select="."/>
      <prolog>
        <xsl:apply-templates mode="topicMetadata"/>
      </prolog>
      <refbody>        
        <xsl:apply-templates mode="#current" select="node()"/>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template match="compounddef[@kind = ('dir')]" priority="10">
    <reference id="{local:getId(.)}" outputclass="{name(.)} {@kind}">
      <title>File List</title>
      <xsl:apply-templates mode="shortDesc" select="."/>
      <prolog>
        <xsl:apply-templates mode="topicMetadata"/>
      </prolog>
      <refbody>
        <section outputclass="dir">
          <dl outputclass="directory">
            <dlentry outputclass="dir">
              <dt><xsl:value-of select="compoundname"/></dt>
              <dd>
                <dl outputclass="filelist">
                  <xsl:apply-templates select="innerfile"></xsl:apply-templates>
                </dl>
              </dd>
            </dlentry>
          </dl>
        </section>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template match="innerfile">
    <xsl:variable name="sourceURI" as="xs:string"
         select="concat(@refid, '.xml')"
    />
    <xsl:variable name="sourceDoc" as="document-node()?"
      select="document($sourceURI, .)"
    />
    <dlentry outputclass="file">
      <dt outputclass="filename"><xref keyref="{local:getKey($sourceDoc/*/compounddef)}"><xsl:value-of select="normalize-space(.)"/></xref></dt>
      <dd outputclass="shortdesc">
        <xsl:apply-templates select="$sourceDoc/*/compounddef/briefdescription/node()"/>
      </dd>
    </dlentry>
  </xsl:template>
  
  <xsl:template match="compounddef[@kind = ('union')]" priority="10">
    <reference id="{local:getId(.)}" outputclass="{name(.)} {@kind}">
      <xsl:apply-templates mode="topicTitle" select="."/>
      <xsl:apply-templates mode="shortDesc" select="."/>
      <prolog>
        <xsl:apply-templates mode="topicMetadata"/>
      </prolog>
      <refbody>
        <xsl:call-template name="makeIncludesSection"/>
        <xsl:apply-templates select="node() except (includes)"/>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template match="compounddef[@kind = ('struct')]" priority="10">
    <reference id="{local:getId(.)}" outputclass="{name(.)} {@kind}">
      <xsl:apply-templates mode="topicTitle" select="."/>
      <xsl:apply-templates mode="shortDesc" select="."/>
      <prolog>
        <xsl:apply-templates mode="topicMetadata"/>
      </prolog>
      <refbody>
        <xsl:call-template name="makeIncludesSection"/>
        <xsl:apply-templates select="node() except (includes)"/>
     </refbody>
      <xsl:apply-templates mode="summary" select="sectiondef[@kind = ('public-func')]"/>
      <xsl:apply-templates mode="summary" select="sectiondef[@kind = ('public-attrib')]"/>
      <!-- Detailed description of the file itself: -->
      <xsl:apply-templates select="detaileddescription" mode="makeTopic"/>
      <xsl:apply-templates mode="detailedDescriptionSubtopics" select="sectiondef[@kind = ('public-func')]"/>
    </reference>
  </xsl:template>
  
  <xsl:template match="compounddef[@kind = ('file')]" priority="10">
    <reference id="{local:getId(.)}" outputclass="{name(.)} {@kind}">
      <xsl:apply-templates mode="topicTitle" select="."/>
      <xsl:apply-templates mode="shortDesc" select="."/>
      <prolog>
        <xsl:apply-templates mode="topicMetadata"/>
      </prolog>
      <refbody>
        <xsl:call-template name="makeIncludesSection"/>
        <xsl:apply-templates select="programlisting" mode="makeExternalPageLink"/>
      </refbody>
      <!-- Summary topics: -->
      <xsl:call-template name="makeDataStructuresTopic"/>
      <xsl:apply-templates mode="summary" select="sectiondef[@kind = ('define')]"/>
      <xsl:apply-templates mode="summary" select="sectiondef[@kind = ('typedef')]"/>
      <xsl:apply-templates mode="summary" select="sectiondef[@kind = 'enum']"/>
      <xsl:apply-templates mode="summary" select="sectiondef[@kind = ('func')]"/>
      <!-- Detailed description of the file itself: -->
      <xsl:apply-templates select="detaileddescription" mode="makeTopic"/>
      <xsl:apply-templates mode="detailedDescriptionSubtopics" select="sectiondef[@kind = ('define')]"/>
      <xsl:apply-templates mode="detailedDescriptionSubtopics" select="sectiondef[@kind = ('typedef')]"/>
      <xsl:apply-templates mode="detailedDescriptionSubtopics" select="sectiondef[memberdef[@kind = ('enum')]]"/>
      <xsl:apply-templates mode="detailedDescriptionSubtopics" select="sectiondef[@kind = ('func')]"/>
    </reference>
  </xsl:template>
  
  <xsl:template mode="makeTopic" match="compounddef[@kind = ('struct')]/detaileddescription">
    <reference id="{local:getId(.)}" outputclass="{name(.)}">
      <title>Detailed Description</title>
      <refbody>
        <section>
          <xsl:apply-templates select="preceding-sibling::briefdescription/*"/>
          <xsl:apply-templates/>
        </section>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template mode="makeTopic" match="compounddef[@kind = ('file')]/detaileddescription">
    <reference id="{local:getId(.)}" outputclass="{name(.)}">
      <title>Detailed Description</title>
      <refbody>
        <section>
          <xsl:apply-templates select="preceding-sibling::briefdescription/*"/>
        </section>
        <xsl:apply-templates/>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template match="para[simplesect]" priority="10">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] para[simplesect]</xsl:message>
    </xsl:if>
    <!-- Don't generate paragraphs for paras that contain simplesect -->
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="para/simplesect[@kind = ('copyright')]" priority="10">
    <section spectitle="Copyright">
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  
  <xsl:template match="para/simplesect[@kind = ('date', 'author')]" priority="10">
    <section outputclass="{@kind}" spectitle="{@kind}">
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  
  <xsl:template match="variablelist">
    <parml>
      <xsl:for-each-group select="*" group-ending-with="listitem">
        <plentry>
          <xsl:apply-templates select="current-group()"/>
        </plentry>
      </xsl:for-each-group>
    </parml>
  </xsl:template>
  
  <xsl:template match="variablelist/varlistentry">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="term">
    <pt>
      <xsl:apply-templates select="anchor"/>
      <xsl:apply-templates select="node() except (anchor)"/></pt>
  </xsl:template>
  
  <xsl:template match="anchor">
    <xsl:sequence select="@id"/>
  </xsl:template>
    
  <xsl:template match="variablelist/listitem">
    <pd><xsl:apply-templates/></pd>
  </xsl:template>  
  
  <xsl:template name="makeDataStructuresTopic">
    <!-- Context is a compounddef element
      
         Output context is topic body
    -->
    <xsl:if
      test="innerclass">
      <reference id="{local:getId(., 'data-structures')}" outputclass="struct declSummary">
        <title>Data Structures</title>
        <refbody>
          <xsl:apply-templates select="innerclass" mode="summary"/>
        </refbody>
      </reference>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="innerclass" mode="summary">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] summary: innerclass: <xsl:value-of select="."/></xsl:message>
    </xsl:if>
    
    <xsl:variable name="sourceURI" as="xs:string"
         select="concat(@refid, '.xml')"
    />
    <xsl:variable name="sourceDoc" as="document-node()?"
      select="document($sourceURI, .)"
    />
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] summary: innerclass: sourceDoc=<xsl:value-of select="document-uri($sourceDoc)"/></xsl:message>
    </xsl:if>
    <xsl:if test="not($sourceDoc)">
      <xsl:message> - [WARN] Failed to find document for inner class with URI "<xsl:value-of select="$sourceURI"/>"</xsl:message>
    </xsl:if>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] summary: innerclass: Applying templates to $sourceDoc/*/compounddef in mode "summary".</xsl:message>
    </xsl:if>
    <xsl:apply-templates select="$sourceDoc/*/compounddef" mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="summary" match="compounddef">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] summary: compounddef, id="<xsl:value-of select="@id"/>"</xsl:message>
    </xsl:if>
    
    <section outputclass="declSummary {@kind}">
      <sectiondiv outputclass="kind"><xsl:value-of select="@kind"/></sectiondiv>
      <sectiondiv outputclass="name"><xsl:value-of select="compoundname"/></sectiondiv>
      <!-- Brief descriptions appear to have either zero or one paragraphs, so this
           logic should be safe
        -->
      <sectiondiv outputclass="briefdescription">
        <p>
          <xsl:apply-templates select="briefdescription" mode="#current">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates>
          <xref outputclass="more-link" keyref="{@id}">More...</xref>
        </p>
      </sectiondiv>
    </section>
  </xsl:template>
  
  <xsl:template name="makeIncludesSection">
    <!-- Context is a compounddef element
      
         Output context is topic body
    -->
    <xsl:if
      test="includes">
      <section
        outputclass="includes">
        <!-- Includes are formatted to look like literal C++ #include
                 directives, one per line. So putting them within
                 codeblock.
              -->
        <codeblock>
          <xsl:apply-templates mode="makeIncludesSection"
            select="includes"/>
        </codeblock>
      </section>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="includes" mode="makeIncludesSection">
    <xsl:choose>
      <xsl:when test="matches(normalize-space(.), '/[\w+].*')">
        <xsl:message> + [INFO] Ignoring include to absolute path or URL:" <xsl:value-of select="."/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <ph outputclass="{name(.)}">
          <xsl:text>#include </xsl:text>
          <xsl:apply-templates mode="makeIncludeFileref" select="."/>
        </ph>
        <xsl:text>&#x0a;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="includes">
    <!-- Suppress includes in default context -->
  </xsl:template>
  
  <xsl:template mode="makeIncludeFileref" match="includes[@local= ('yes')]" priority="10">   
    <xsl:text>"</xsl:text>
    <xsl:apply-templates mode="makeIncludeFileLink" select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>
  
  <xsl:template mode="makeIncludeFileref" match="includes">
    <xsl:text>&lt;</xsl:text>
    <xsl:apply-templates mode="makeIncludeFileLink" select="."/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>
  
  <xsl:template mode="makeIncludeFileLink" match="includes">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template mode="makeIncludeFileLink" match="includes[@refid]" priority="10">
    <xsl:param name="wrapXref" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="key" as="xs:string"
      select="local:getKey(.)"
    />
    <xsl:choose>
      <xsl:when test="$wrapXref">
        <ph><xref keyref="{$key}"><xsl:apply-templates/></xref></ph>
      </xsl:when>
      <xsl:otherwise>
        <xref keyref="{$key}"><xsl:apply-templates/></xref>    
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template mode="summary" match="sectiondef[@kind = ('public-attrib')]">
    <reference id="{local:getId(.)}" outputclass="{@kind} declSummary">
      <title>Data Fields</title>
      <refbody>
        <xsl:apply-templates select="memberdef[@kind = ('variable')]" mode="summary"/>
      </refbody>
    </reference>
  </xsl:template>
    
  <xsl:template mode="summary" match="sectiondef[@kind = ('public-func')]">
    <reference id="{local:getId(.)}" outputclass="{@kind} declSummary">
      <title>Functions</title>
      <refbody>
        <xsl:apply-templates select="memberdef[@kind = ('function')]" mode="summary"/>
      </refbody>
    </reference>
  </xsl:template>
    
  <xsl:template mode="summary" match="memberdef[@kind = ('variable')]">
    <section outputclass="declSummary {@kind}" id="{local:getId(.)}">
      <sectiondiv outputclass="kind">#<xsl:value-of select="@kind"/></sectiondiv>
      <sectiondiv outputclass="name"><xsl:value-of select="name"/></sectiondiv>
      <xsl:if test="param">
        <sectiondiv outputclass="params">
          <xsl:apply-templates select="param"/>
        </sectiondiv>
      </xsl:if>
      <xsl:if test="initializer">
        <sectiondiv outputclass="initializer">
          <xsl:apply-templates select="initializer"/>
        </sectiondiv>
      </xsl:if>
      <xsl:apply-templates select="briefdescription" mode="#current"/>
    </section>
  </xsl:template>
    
  <xsl:template mode="summary" match="sectiondef[@kind = ('typedef')]">
    <reference id="{local:getId(.)}" outputclass="typedefs declSummary"> 
      <title>Typedefs</title>
      <refbody>
        <xsl:apply-templates select="memberdef[@kind = ('typedef')]" mode="#current"/>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template mode="summary" match="memberdef[@kind = ('typedef')]">
    <section outputclass="declSummary {@kind}" id="{@id}">
      <sectiondiv outputclass="kind"><xsl:value-of select="@kind"/></sectiondiv>
      <sectiondiv outputclass="type"><xsl:apply-templates select="type"/></sectiondiv>
      <sectiondiv outputclass="name"><xsl:value-of select="name"/></sectiondiv>
      <xsl:apply-templates select="argsstring"/>
      <xsl:apply-templates select="definition"/>
      <xsl:apply-templates select="briefdescription" mode="#current"/>
      <xsl:if test="not(matches(detaileddescription, '^\s*$'))">
        <xref keyref="{@id}">More...</xref>
      </xsl:if>
    </section>
  </xsl:template>
  
  <xsl:template mode="summary" match="sectiondef[@kind = ('define')]">
    <reference id="{local:getId(.)}" outputclass="defines declSummary"> 
      <title>Macros</title>
      <refbody>
        <xsl:apply-templates select="memberdef[@kind = ('define')]" mode="#current"/>
      </refbody>
    </reference>
  </xsl:template>

  <xsl:template mode="summary" match="memberdef[@kind = ('define')]">
    <section outputclass="declSummary {@kind}"
      id="{local:getId(.)}"
      >
      <sectiondiv outputclass="kind">#define</sectiondiv>
      <sectiondiv outputclass="name"><xsl:value-of select="name"/></sectiondiv>
      <xsl:if test="param">
        <sectiondiv outputclass="parameters">
          <xsl:apply-templates select="param"/>
        </sectiondiv>
      </xsl:if>
      <xsl:apply-templates select="initializer"/>
      <xsl:apply-templates select="briefdescription" mode="#current"/>
      <xsl:if test="not(matches(detaileddescription, '^\s*$'))">
        <xref keyref="{@id}">More...</xref>
      </xsl:if>
    </section>
  </xsl:template>
  
  <xsl:template mode="summary" match="sectiondef[@kind = ('func')]">
    <reference id="{local:getId(.)}" outputclass="functions declSummary">
      <title>Functions</title>
      <refbody>
        <xsl:apply-templates mode="#current" select="memberdef"/>
      </refbody>
      <xsl:apply-templates 
        select="../sectiondef[@kind = ('user-defined')][memberdef[@kind = 'function']]"
        mode="#current"
      />
    </reference>
  </xsl:template>
  
  <xsl:template mode="summary" 
       match="sectiondef[@kind = ('user-defined')][memberdef[@kind = 'function']]">
    <xsl:if test="not(matches(briefdescription, '^\s*$'))">
      <reference id="{local:getId(.)}">
        <title><xsl:apply-templates select="header"/></title>
        <refbody>
          <xsl:apply-templates select="description"/>
          <xsl:apply-templates mode="#current" select="memberdef"/>
        </refbody>
      </reference>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="description">
    <section outputclass="{name(.)}">
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  
  <xsl:template match="header">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template mode="summary" match="memberdef[@kind = ('function')]">
    <xsl:if test="not(matches(briefdescription, '^\s*$'))">
      <section outputclass="declSummary {@kind}" id="{local:getId(.)}">
        <sectiondiv outputclass="kind"><xsl:value-of select="@kind"/></sectiondiv>
        <sectiondiv outputclass="type"><xsl:apply-templates select="type"/></sectiondiv>
        <sectiondiv outputclass="name"><xsl:value-of select="name"/></sectiondiv>
        <xsl:apply-templates select="argsstring"/>
        <xsl:if test="param">
          <sectiondiv outputclass="parameters">
            <xsl:apply-templates select="param"/>
          </sectiondiv>  
        </xsl:if>
        <xsl:apply-templates select="definition"/>
        <xsl:apply-templates select="briefdescription" mode="#current"/>
        <xsl:if test="not(matches(detaileddescription, '^\s*$'))">
          <xref keyref="{@id}">More...</xref>
        </xsl:if>
      </section>
    </xsl:if>
  </xsl:template>

  <xsl:template match="sectiondef[@kind = 'enum']" mode="summary">
    <reference id="{local:getId(.)}" outputclass="enumerations declSummary"> 
      <title>Enumerations</title>
      <refbody>
        <xsl:apply-templates select="memberdef[@kind = ('enum')]" mode="#current"/>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template mode="summary" match="memberdef[@kind = ('enum')]">
    <section outputclass="declSummary {@kind}" id="{local:getId(.)}">
      <sectiondiv outputclass="kind"><xsl:value-of select="@kind"/></sectiondiv>
      <sectiondiv outputclass="name"><xsl:value-of select="name"/></sectiondiv>
      <sectiondiv outputclass="enumvalues">
        <xsl:apply-templates select="enumvalue"/>
      </sectiondiv>
      <xsl:apply-templates select="briefdescription" mode="#current"/>
      <xsl:if test="not(matches(detaileddescription, '^\s*$')) or
        (not(matches(briefdescription, '^\s*$')) and 
         enumvalue[not(matches(briefdescription, '^\s*$'))])
        ">
        <xref keyref="{@id}">More...</xref>
      </xsl:if>
    </section>
  </xsl:template>
  
  <xsl:template match="enumvalue">
    <xsl:if test="count(preceding-sibling::enumvalue) gt 0">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <ph outputclass="{name(.)}" id="{local:getId(.)}">
      <ph outputclass="name"><xsl:value-of select="name"/></ph>
      <ph outputclass="initializer"><xsl:value-of select="initializer"/></ph>
    </ph>
  </xsl:template>

  <xsl:template match="compounddef/briefdescription |
                       compounddef/compoundname"
    >
    <!-- Handled in specific modes. Suppress in default mode -->
  </xsl:template>
  
  <xsl:template mode="summary" match="compounddef/briefdescription" priority="10">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template mode="summary" match="briefdescription" 
                        
    >
    <sectiondiv outputclass="{name(.)}">    
      <xsl:apply-templates mode="#current"/>
    </sectiondiv>
  </xsl:template>
  
  <xsl:template mode="summary" match="compounddef/briefdescription/para" priority="10">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template mode="summary" match="briefdescription/para">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  
  <xsl:template mode="summary" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:template match="compounddef/detaileddescription | 
                       compounddef/inbodydescription">
    <section outputclass="{name(.)}">
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  
  <xsl:template match="compounddef/location">
    <!-- Suppress in default mode -->
  </xsl:template>
  
  <xsl:template match="sectiondef[@kind = ('public-attrib')]" mode="makeSectionContents">
    <xsl:if test="memberdef">
      <sectiondiv outputclass="memberdecls">
        <xsl:apply-templates select="memberdef"/>
      </sectiondiv>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="sectiondef" mode="makeSectionContents" priority="-0.25">
    <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="sectiondef">  
    <xsl:variable name="title">
      <xsl:call-template name="getSectionDefTitle"/>
    </xsl:variable>
    <xsl:if test="not(matches(., '^\s*$'))">
      <section outputclass="{@kind}" id="{local:getId(.)}">
        <xsl:if test="normalize-space($title) != ''">
          <xsl:attribute name="spectitle" select="$title"/>
        </xsl:if>
        <xsl:apply-templates mode="makeSectionContents" select="."/>
      </section>
    </xsl:if>     
  </xsl:template>
  
  <xsl:template name="getSectionDefTitle">
    <xsl:choose>
      <xsl:when
        test="@kind">
        <xsl:variable
          name="kind"
          as="xs:string"
          select="@kind"/>
        <title><xsl:value-of select="local:getLabelForKind($kind)"/></title>
      </xsl:when>
      <xsl:otherwise>
        <!-- No title -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="memberdef">
    <sectiondiv outputclass="{@kind}" id="{local:getId(.)}">
      <sectiondiv outputclass="memberdefinition">
        <xsl:apply-templates select="@*" mode="makeDataElementsFromAttributes"/>
        <xsl:apply-templates mode="#current" 
          select="type | name | argsstring | definition"/>
      </sectiondiv>      
      <xsl:apply-templates mode="#current"
         select="* except (type | name | argsstring | definition)"
      />
    </sectiondiv>
  </xsl:template>
  
  <xsl:template match="memberdef[@kind = 'function']" priority="10">
    <xsl:if test="not(matches(briefdescription, '^\s*$'))">
      <sectiondiv outputclass="{@kind}">
        <sectiondiv outputclass="memberdefinition">
          <xsl:apply-templates mode="#current" 
            select="type | name | argsstring | definition"/>
        </sectiondiv>
        <sectiondiv outputclass="parameters">
          <xsl:apply-templates select="param"/>
        </sectiondiv>  
        <xsl:apply-templates mode="#current"
           select="* except (type | name | argsstring | definition | param)"
        />
      </sectiondiv>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="location">
    <!-- Suppress by default -->
  </xsl:template>  
  
  <xsl:template match="ref">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="sourceDocs" as="document-node()*" tunnel="yes"/>
    <xsl:param name="wrapXref" as="xs:boolean" tunnel="yes" select="false()"/>
    
<!--    <xsl:variable name="doDebug" as="xs:boolean"
      select="string(@refid) = ('_o_v_r___c_a_p_i_8h_1a026a4136bb5a5b86f0e51c8bff4db490')"
    />
-->    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] ref: refid="<xsl:value-of select="@refid"/>"</xsl:message>
    </xsl:if>
    
    <xsl:variable name="refid" as="xs:string" select="@refid"/>
    
    <xsl:variable name="targets" as="element()*"
      
    >
      <!-- Look across all the source docs for the target. 
        
        -->
      <xsl:for-each select="$sourceDocs">
        <xsl:sequence select="key('elemsByID', $refid, .)"/>
      </xsl:for-each>
    </xsl:variable>
    <!-- Get the first target in case there are multiples (which should never happen): -->
    <xsl:variable name="target" as="element()?" select="$targets[1]"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] ref: target: <xsl:value-of select="$target/@kind"/> (<xsl:value-of select="$target/name"/>)</xsl:message>
      <xsl:message> + [DEBUG] ref: containing doc: <xsl:value-of select="document-uri(root($target))"/></xsl:message>
    </xsl:if>
    <!-- Determine if the target is an element that will not generate
         a separate topic and thus needs to be addressed as a non-topic
         element within it's parent topic.
      -->
    <xsl:variable name="isLocalRef" as="xs:boolean"
      select="boolean($target) and 
              (($target/@kind = ('typedef', 'enum', 'define', 'function', 'variable')) or
               ($target/self::enumvalue)
              ) and 
              matches($target/detaileddescription, '^\s*$')
              and not(local:isEnumWithDetails($target))
              "
    />
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] ref: isLocalRef="<xsl:value-of select="$isLocalRef"/>"</xsl:message>
    </xsl:if>
    <xsl:variable name="parentTopicGenerator" as="element()"      
    >
      <xsl:apply-templates mode="getTopicMakingParent" select="$target">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:variable name="targetKey" as="xs:string"
      select="if ($isLocalRef)
                 then local:getKey($parentTopicGenerator)
                 else local:getKey(.)
      "
    />
    <xsl:variable name="targetID" as="xs:string"
      select="if ($isLocalRef) 
                 then concat('/', @refid) 
                 else ''"
    />
    <xsl:choose>
      <xsl:when test="$wrapXref">
        <ph><xref keyref="{$targetKey}{$targetID}" outputclass="{@kindref}"><xsl:apply-templates/></xref></ph>
      </xsl:when>
      <xsl:otherwise>
        <xref keyref="{$targetKey}{$targetID}" outputclass="{@kindref}"><xsl:apply-templates/></xref>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="getTopicMakingParent" match="enumvalue" as="element()">
    <xsl:apply-templates select=".." mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="getTopicMakingParent" match="memberdef" as="element()">
    <xsl:sequence 
      select="if (matches(detaileddescription, '^\s*$'))
                 then ..
                 else .
      "
    />
  </xsl:template>
  
  <xsl:template mode="getTopicMakingParent" match="*" priority="-1" as="element()">
    <xsl:sequence select=".."/>
  </xsl:template>
  
  <xsl:template match="collaborationgraph | inheritancegraph | incdepgraph">
    <!-- Suppressing graphs for now. -->
  </xsl:template>
  
  <xsl:template match="node">
    <sectiondiv outputclass="{name(.)}" id="node_{@id}">
      <xsl:apply-templates/>
    </sectiondiv>
  </xsl:template>
  
  <xsl:template match="node/label">
    <ph outputclass="{name(.)}"><xsl:apply-templates/></ph>
  </xsl:template>
  
  <xsl:template match="node/link" priority="10">
    <xsl:param name="wrapXref" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:choose>
      <xsl:when test="$wrapXref">
        <ph>    <xref keyref="{local:getKey(.)}"><xsl:apply-templates/></xref></ph>
      </xsl:when>
      <xsl:otherwise>
        <xref keyref="{local:getKey(.)}"><xsl:apply-templates/></xref>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="childnode">
    <ph outputclass="{name(.)}">
      <xref href="#./node_{@refid}"><xsl:apply-templates/></xref>
    </ph>
  </xsl:template>
  
  <xsl:template match="edgelabel">
    <ph outputclass="{name(.)}"><xsl:apply-templates/></ph>
  </xsl:template>
  
  <xsl:template  
    match="type | 
           name | 
           param |
           type |
           array |
           declname |           
           defval |
           initializer |
           argsstring | 
           definition | 
           briefdescription | 
           detaileddescription | 
           inbodydescription">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] <xsl:value-of select="name(.)"/>: normalize-space(.) != '' = <xsl:value-of select="normalize-space(.) != ''"/>"</xsl:message>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="normalize-space(.) != ''">
        <sectiondiv outputclass="{name(.)}">
          <xsl:apply-templates/>
        </sectiondiv>        
      </xsl:when>
      <xsl:otherwise>
        <!-- Don't put anything out -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="defname">
    <ph outputclass="{name(.)}"><xsl:apply-templates/></ph>
  </xsl:template>
  
  <xsl:template match="para[xrefsect]" mode="#default makeMemberdefEnumeratorSection" priority="10">
    <!-- Don't emit a <p> in this case as the xrefsect makes a sectiondiv -->
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="para" mode="#default makeMemberdefEnumeratorSection">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] para base template</xsl:message>
    </xsl:if>
    <p><xsl:apply-templates/></p>
  </xsl:template>
  
  <xsl:template match="para[linebreak]" priority="10" mode="#default makeMemberdefEnumeratorSection">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] para[linebreak]</xsl:message>
    </xsl:if>
    <xsl:for-each-group select="node()" group-ending-with="linebreak">
      <p><xsl:apply-templates select="current-group()"/></p>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="verbatim">
    <codeblock><xsl:apply-templates/></codeblock>
  </xsl:template>
  
  <xsl:template match="ulink">
    <!-- 
      <ulink url="http://www.oculusvr.com/licenses/LICENSE-3.2">http://www.oculusvr.com/licenses/LICENSE-3.2</ulink>
      -->
    
    <xsl:param name="wrapXref" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:choose>
      <xsl:when test="$wrapXref">
        <ph><xref href="{@url}" 
      scope="external"
      format="html"><xsl:apply-templates/></xref></ph>
      </xsl:when>
      <xsl:otherwise>
        <xref href="{@url}" 
      scope="external"
      format="html"><xsl:apply-templates/></xref>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="xrefsect | xrefdescription">
    <sectiondiv outputclass="{name(.)}">
      <xsl:apply-templates/>
    </sectiondiv>
  </xsl:template>
  
  <xsl:template match="xreftitle">
    <p outputclass="{name(.)}"><xsl:apply-templates/></p>
  </xsl:template>
  
  <xsl:template match="linebreak"/><!-- Suppress -->
  
  <xsl:template match="simplesect[@kind = 'see']">
    <xsl:text>See </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="simplesect[@kind = 'note']">
    <note><xsl:apply-templates/></note>
  </xsl:template>
  
  <xsl:template match="simplesect[@kind = 'see']/para">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] simplesect[@kind = 'see']/para</xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="itemizedlist">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  
  <xsl:template match="orderedlist">
    <ol>
      <xsl:apply-templates/>
    </ol>
  </xsl:template>
  
  <xsl:template match="listitem">
    <li><xsl:apply-templates/></li>
  </xsl:template>
  
  <xsl:template match="emphasis">
    <i><xsl:apply-templates/></i>
  </xsl:template>  
  
  <xsl:template match="bold">
    <b><xsl:apply-templates/></b>
  </xsl:template>  
  
  <xsl:template match="programlisting">
    <section spectitle="Program Listing">
      <codeblock><xsl:apply-templates/></codeblock>
    </section>
  </xsl:template>

  <xsl:template match="para/programlisting" mode="#default makeMemberdefEnumeratorSection" priority="10">
    <codeblock>
      <xsl:apply-templates mode="#current"/>
    </codeblock>
  </xsl:template>
  
  <xsl:template match="programlisting" mode="makeExternalPageLink">
    <xsl:variable name="targetKey" as="xs:string" 
      select="local:getKey(.)"
    />
    <section outputclass="programlisting-link">
      <p><xref keyref="{$targetKey}">Go to the source code of this file.</xref></p>
    </section>
  </xsl:template>
  
  <xsl:template match="parameterlist">
    <parml>
      <xsl:apply-templates/>
    </parml>
  </xsl:template>
  
  <xsl:template match="parameteritem">
    <plentry>
      <xsl:apply-templates/>
    </plentry>
  </xsl:template>
  
  <xsl:template match="parameternamelist">
   <pt><xsl:apply-templates/></pt>
  </xsl:template>
  
  <xsl:template match="parametername">
   <parmname><xsl:apply-templates/></parmname>
  </xsl:template>
  
  <xsl:template match="parameterdescription">
   <pd><xsl:apply-templates/></pd>
  </xsl:template>
  
  <xsl:template match="p//*">
    <ph outputclass="{name(.)}"><xsl:apply-templates/></ph>
  </xsl:template>
  
  <xsl:template match="listofallmembers">
    <!-- Suppress -->
  </xsl:template>
  
  <xsl:template match="compound/name | 
                       compounddef/title
                      ">
    <title><xsl:apply-templates/></title>
  </xsl:template>

  <!-- =========================
       Mode detailedDescriptionSubtopics
       
       Generates subtopics for memberdefs
       with detailed descriptions, organized
       into groups by kind.
       ========================= -->

  <xsl:template mode="detailedDescriptionSubtopics" match="sectiondef">    
    <xsl:variable name="memberType" as="xs:string"
      select="local:getMemberTypeForSectionType(@kind)"
    />
    <xsl:if test="$memberType = 'unknown'">
      <xsl:message> - [WARN] Unknown member type for section type "<xsl:value-of select="@kind"/>"</xsl:message>
    </xsl:if>
    <reference id="{local:getId(., 'full-topics')}">
      <title><xsl:value-of select="local:getLabelForKind(@kind, false())"/> Documentation</title>
      <xsl:apply-templates mode="fullTopics"
        select="../sectiondef/memberdef[@kind = $memberType]"
      />
    </reference>
  </xsl:template>

  <xsl:template mode="detailedDescriptionSubtopics" match="sectiondef[@kind = ('user-defined')]" priority="10">
    <!-- Skip, already contribute to the main file topic body -->
  </xsl:template>

  <!-- =========================
       Mode make data elements
       from attributes
       ========================= -->
  
  <xsl:template mode="makeDataElementsFromAttributes" match="@prot | @static | @mutable">
    <data name="{name(.)}" value="{.}"/>
  </xsl:template>

  <xsl:template mode="makeDataElementsFromAttributes" match="@*" priority="-1">
    <!-- No data element by default -->
  </xsl:template>

  <!-- =========================
       Mode topicTitle
       ========================= -->
  
  <xsl:template mode="topicTitle" match="compounddef">
    <xsl:variable name="compoundName" as="xs:string"
      select="string(compoundname)"
    />
    <xsl:variable name="titleString" as="xs:string"
      select="tokenize($compoundName, '::')[last()]"
    />
    <title>
      <xsl:value-of select="$titleString"/> 
      <xsl:text> </xsl:text>
      <xsl:value-of select="local:getLabelForKind(@kind, false())"/></title>
  </xsl:template>
  
  <xsl:template mode="topicTitle" match="*" priority="-1">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- =========================
       Mode shortDesc
       ========================= -->
  
  <xsl:template mode="shortDesc" match="compounddef">
    <xsl:apply-templates mode="#current" select="briefdescription"/>
  </xsl:template>
  
  <xsl:template mode="shortDesc" match="briefdescription">
    <shortdesc><xsl:apply-templates mode="#current">
      <xsl:with-param name="wrapXref" as="xs:boolean" tunnel="yes" select="true()"/>
    </xsl:apply-templates></shortdesc>
  </xsl:template>
  
  <xsl:template mode="shortDesc" match="para">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] shortDesc: para</xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- =========================
       Mode topicMetadata
       ========================= -->
  
  <xsl:template match="compounddef/location" mode="topicMetadata">
    <!-- The location is in attributes in the source XML and wouldn't normally be displayed,
         but it might be useful as metadata.
      -->
    <data name="{name(.)}" value="{@file}"/>
  </xsl:template>
  
  <xsl:template mode="topicMetadata" match="*" priority="-1">
    <!-- Most elements do not contribute to the prolog -->
  </xsl:template>  
  
  <xsl:template mode="topicMetadata" match="text()">
    <!-- Most elements do not contribute to the prolog -->
  </xsl:template>


  <!-- =========================
       Mode fullTopics

NOTE: The result-document logic is
       in the code that generates the corresponding
       topicref to the topic. All topics must be 
       referenced by topicref from the map, so it
       makes sense to generate the result document
       at the time the topicref is constructed.
       ========================= -->
  
  <!-- Fallback for memberdefs with unhandled @kind values -->
  <xsl:template mode="fullTopics" match="memberdef" priority="-0.5">
    <reference id="{local:getId(.)}" outputclass="{@kind}">
      <title><xsl:apply-templates select="name" mode="topicTitle"/></title> 
      <refbody>
        <section>
          <xsl:apply-templates/>
        </section>
      </refbody>
    </reference>
  </xsl:template>
  
  <!-- For most memberdefs, if there's no detailed description, don't
       generated a topic. 
    -->
  <xsl:template mode="fullTopics" match="memberdef[matches(detaileddescription, '^\s*$')]" priority="5">
    <!-- No topic for you. -->
  </xsl:template>
  
  <xsl:template mode="fullTopics" match="memberdef[@kind = ('enum')]" priority="10">
    <xsl:choose>
      <xsl:when test="local:isEnumWithDetails(.)">
        <xsl:call-template name="makeFullTopicForMemberdef"/>        
      </xsl:when>
      <xsl:otherwise>
        <!-- No topic for you -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="makeFullTopicForMemberdef" 
    mode="fullTopics" match="memberdef[@kind = ('function', 'define', 'enum', 'typedef', 'variable')]">
    
    <reference id="{local:getId(.)}" outputclass="{@kind}">
      <xsl:apply-templates select="." mode="makeMemberdefDocTitle"/>
      <refbody>
        <section>
          <xsl:apply-templates select="briefdescription, detaileddescription" mode="makeMemberdefDocTopic"/>
        </section>
        <xsl:apply-templates select="." mode="makeMemberdefParametersSection"/>
        <xsl:apply-templates select="." mode="makeMemberdefReturnsSection"/>
        <xsl:apply-templates select="." mode="makeMemberdefSeeAlsoSection"/>
        <xsl:apply-templates select="." mode="makeMemberdefEnumeratorSection"/>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefDocTopic" match="briefdescription | detaileddescription">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:apply-templates select="* except (para[parameterlist | simplesect])"/>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefDocTitle" match="memberdef">
   <title><xsl:apply-templates select="type, name" mode="#current"/> 
     <xsl:if test="param">
       <xsl:text> ( </xsl:text>
         <xsl:apply-templates select="param" mode="#current"/>
       <xsl:text> ) </xsl:text>  
     </xsl:if>
     <xsl:apply-templates select="initializer" mode="#current"/>
   </title>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefDocTitle" match="memberdef[@kind = 'define']" priority="10">
   <title><xsl:text>#define </xsl:text><xsl:apply-templates select="type, name, argsstring" mode="#current"/></title>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefDocTitle" match="memberdef[@kind = 'typedef']" priority="10">
   <title><xsl:text>typedef </xsl:text><xsl:apply-templates select="type, name, argsstring" mode="#current"/></title>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefDocTitle" match="memberdef[@kind = 'enum']" priority="10">
   <title><xsl:text>enum </xsl:text><xsl:apply-templates select="name" mode="#current"/></title>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefDocTitle" match="type | name | declname | defname | initializer | argsstring">
    <ph outputclass="{name(.)}"><xsl:apply-templates/></ph>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefDocTitle" match="param">
    <xsl:if test="count(preceding-sibling::param) gt 0">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <ph outputclass="{name(.)}"><xsl:apply-templates select="type, declname, defname" mode="#current"/></ph>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefParametersSection" match="memberdef">
    <xsl:apply-templates select="detaileddescription/para/parameterlist" mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefParametersSection" match="parameterlist">
    <section spectitle="Parameters">
      <xsl:apply-templates select="."/>
    </section>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefReturnsSection" match="memberdef">
    <xsl:apply-templates mode="#current" select="detaileddescription/para/simplesect[@kind = ('return')]"/>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefReturnsSection" match="simplesect[@kind = ('return')]">
    <section spectitle="Return">
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefSeeAlsoSection" match="memberdef">
    <xsl:apply-templates mode="#current" select="detaileddescription/para/simplesect[@kind=('see')]"/>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefSeeAlsoSection" match="simplesect[@kind = ('see')]">
    <section spectitle="See also">
      <xsl:apply-templates mode="#current"/>
    </section>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefSeeAlsoSection" match="para">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] makeMemberdefSeeAlsoSection: applying next match</xsl:message>
    </xsl:if>
    <xsl:next-match>
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:next-match>
  </xsl:template>

  <xsl:template mode="makeMemberdefEnumeratorSection" match="memberdef">
    <!-- No enumvalue, nothing to do -->
  </xsl:template>

  <xsl:template mode="makeMemberdefEnumeratorSection" match="memberdef[enumvalue]" priority="10">
    
    <xsl:variable name="rows" as="element()*">
      <xsl:apply-templates mode="makeMemberdefEnumeratorSection" select="enumvalue"/>
    </xsl:variable>
    
    <!-- Only generate the table if there are rows. -->
    
    <xsl:if test="count($rows) > 0">
      <section outputclass="enumerators">
        <table
          frame="all"
          rowsep="1"
          colsep="1">
          <tgroup
            cols="2">
            <colspec
              colname="c1"
              colnum="1"
              colwidth="1.0*"/>
            <colspec
              colname="c2"
              colnum="2"
              colwidth="1.0*"/>
            <thead>
              <row>
                <entry
                  namest="c1"
                  nameend="c2">Enumerator</entry>
              </row>
            </thead>
            <tbody>
              <xsl:sequence select="$rows"/>
            </tbody>
          </tgroup>
        </table>
      </section>
    </xsl:if>
    
  </xsl:template>

  <xsl:template mode="makeMemberdefEnumeratorSection" match="enumvalue">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] makeMemberdefEnumeratorSection: enumvalue = <xsl:value-of select="name"/></xsl:message>
      <xsl:message> + [DEBUG] makeMemberdefEnumeratorSection: enumvalue = briefdescription = "<xsl:value-of select="briefdescription"/>"</xsl:message>
      <xsl:message> + [DEBUG] makeMemberdefEnumeratorSection: not(matches(briefdescription, '^\s*$'))=<xsl:value-of select="not(matches(briefdescription, '^\s*$'))"/></xsl:message>
      
    </xsl:if>
    <!-- Don't create a row if there's no brief description -->
    <xsl:if test="not(matches(briefdescription, '^\s*$'))">
      <row>
        <entry>
          <xsl:apply-templates select="name" mode="makeMemberdefDocTitle"/>
        </entry>
        <entry>
          <xsl:apply-templates select="briefdescription, detaileddescription"
            mode="#current"
            >
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
          </xsl:apply-templates>
        </entry>
      </row>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="makeMemberdefEnumeratorSection" match="briefdescription | detaileddescription">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] makeMemberdefEnumeratorSection: Got <xsl:value-of select="concat(name(..), '/', name(.))"/>, applying templates in same mode.</xsl:message>
    </xsl:if>
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="fullTopics" match="programlisting">
    <topic id="{local:getKey(.)}" outputclass="{name(.)}">
      <title><xsl:value-of select="../compoundname"/></title>
      <body>
        <p outputclass="doclink">
          <xref keyref="{local:getKey(..)}">Go to the documentation of this file.</xref>
        </p>
        <codeblock>
          <xsl:apply-templates/>
        </codeblock>
      </body>
    </topic>
  </xsl:template>
  
  <xsl:template match="codeline">
    <codeph outputclass="{name(.)}"><xsl:apply-templates select="@*" mode="data"/><xsl:apply-templates/></codeph>
  </xsl:template>
  
  <xsl:template match="codeline/highlight[string(.) = '']" priority="10">    
    <!-- Don't generate for empty elements as they can have no effect -->
  </xsl:template>
  
  <xsl:template match="codeline/highlight">    
    <codeph outputclass="{@class}"><xsl:apply-templates/></codeph>
  </xsl:template>
  
  <xsl:template match="sp">
    <ph outputclass="{name(.)}">&#x20;</ph>
  </xsl:template>
  
  <xsl:template match="@lineno">
    <data name="{name(.)}" value="{.}"/>
  </xsl:template>
  
  <xsl:template mode="fullTopics" match="*" priority="-1">
    <!-- Ignore things by default -->
  </xsl:template>
</xsl:stylesheet>