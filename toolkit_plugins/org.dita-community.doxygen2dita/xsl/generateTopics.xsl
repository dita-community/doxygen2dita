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
    <reference id="{local:getId(.)}">
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
  
  <xsl:template match="compounddef[@kind = ('union', 'struct')]" priority="10">
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
    </reference>
  </xsl:template>
  
  <xsl:template mode="makeTopic" match="detaileddescription">
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
      <reference id="{local:getId(.)}_data-structures">
        <title>Data Structures</title>
        <refbody>
          <xsl:apply-templates select="innerclass" mode="summary"/>
        </refbody>
      </reference>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="innerclass" mode="summary">
    <xsl:variable name="sourceURI" as="xs:string"
         select="concat(@refid, '.xml')"
    />
    <xsl:variable name="sourceDoc" as="document-node()?"
      select="document($sourceURI, .)"
    />
    <xsl:apply-templates select="$sourceDoc/*/compounddef" mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="summary" match="compounddef">
    <section outputclass="declSummary {@kind}">
      <sectiondiv outputclass="kind"><xsl:value-of select="@kind"/></sectiondiv>
      <sectiondiv outputclass="name"><xsl:value-of select="compoundname"/></sectiondiv>
      <xsl:apply-templates select="briefdescription"/>
      <p outputclass="more-link"><xref keyref="{@id}">More...</xref></p>
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
    <ph outputclass="{name(.)}">
      <xsl:text>#include </xsl:text>
      <xsl:apply-templates mode="makeIncludeFileref" select="."/>
    </ph>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>
  
  <xsl:template match="includes">
    <!-- Suprress includes in default context -->
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
  
  <xsl:template mode="summary" match="sectiondef[@kind = ('define')]">
    <reference id="{local:getId(.)}">
      <title>Macros</title>
      <refbody>
        <xsl:apply-templates select="memberdef[@kind = ('define')]" mode="summary"/>
      </refbody>
    </reference>
  </xsl:template>
    
  <xsl:template mode="summary" match="memberdef[@kind = ('define')]">
    <section outputclass="declSummary {@kind}">
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
      <xsl:apply-templates select="briefdescription"/>
    </section>
  </xsl:template>
    
  <xsl:template mode="summary" match="sectiondef[@kind = ('typedef')]">
    <reference id="{local:getId(.)}" outputclass="typedefs"> 
      <title>Typedefs</title>
      <refbody>
        <xsl:apply-templates select="memberdef[@kind = ('typedef')]" mode="summary"/>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template mode="summary" match="memberdef[@kind = ('typedef')]">
    <section outputclass="declSummary {@kind}">
      <sectiondiv outputclass="kind"><xsl:value-of select="@kind"/></sectiondiv>
      <sectiondiv outputclass="type"><xsl:apply-templates select="type"/></sectiondiv>
      <sectiondiv outputclass="name"><xsl:value-of select="name"/></sectiondiv>
      <xsl:apply-templates select="argstring"/>
      <xsl:apply-templates select="definition"/>
      <xsl:apply-templates select="briefdescription"/>
      <xsl:if test="detaileddescription">
        <xref keyref="{@id}">More...</xref>
      </xsl:if>
    </section>
  </xsl:template>

  <xsl:template mode="summary" match="sectiondef[@kind = ('func')]">
    <reference id="{local:getId(.)}" outputclass="functions">
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
    <reference id="{local:getId(.)}">
      <title><xsl:apply-templates select="header"/></title>
      <refbody>
        <xsl:apply-templates select="description"/>
        <xsl:apply-templates mode="#current" select="memberdef"/>
      </refbody>
    </reference>
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
    <section outputclass="declSummary {@kind}">
      <sectiondiv outputclass="kind"><xsl:value-of select="@kind"/></sectiondiv>
      <sectiondiv outputclass="type"><xsl:apply-templates select="type"/></sectiondiv>
      <sectiondiv outputclass="name"><xsl:value-of select="name"/></sectiondiv>
      <xsl:apply-templates select="argstring"/>
      <xsl:if test="param">
        <sectiondiv outputclass="parameters">
          <xsl:apply-templates select="param"/>
        </sectiondiv>  
      </xsl:if>
      <xsl:apply-templates select="definition"/>
      <xsl:apply-templates select="briefdescription"/>
      <xsl:if test="detaileddescription">
        <xref keyref="{@id}">More...</xref>
      </xsl:if>
    </section>
  </xsl:template>

  <xsl:template match="sectiondef[@kind = 'enum']" mode="summary">
    <reference id="{local:getId(.)}" outputclass="enumerations"> 
      <title>Enumerations</title>
      <refbody>
        <xsl:apply-templates select="memberdef[@kind = ('enum')]" mode="summary"/>
      </refbody>
    </reference>
  </xsl:template>
  
  <xsl:template mode="summary" match="memberdef[@kind = ('enum')]">
    <sectiondiv outputclass="declSummary {@kind}">
      <sectiondiv outputclass="kind"><xsl:value-of select="@kind"/></sectiondiv>
      <sectiondiv outputclass="name"><xsl:value-of select="name"/></sectiondiv>
      <sectiondiv outputclass="enumvalues">
        <xsl:apply-templates select="enumvalue"/>
      </sectiondiv>
      <xsl:apply-templates select="briefdescription"/>
      <xsl:if test="detaileddescription">
        <xref keyref="{@id}">More...</xref>
      </xsl:if>
    </sectiondiv>
  </xsl:template>
  
  <xsl:template match="enumvalue">
    <xsl:if test="count(preceding-sibling::enumvalue) gt 0">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <ph outputclass="{name(.)}">
      <ph outputclass="name"><xsl:value-of select="name"/></ph>
      <ph outputclass="initializer"><xsl:value-of select="initializer"/></ph>
    </ph>
  </xsl:template>

  <xsl:template match="argstring">
    <sectiondiv outputclass="args">
      <xsl:apply-templates select="argstring"/>
    </sectiondiv>
  </xsl:template>  
  
  <xsl:template match="compounddef/briefdescription |
                       compounddef/compoundname"
    >
    <!-- Handled in specific modes. Suppress in default mode -->
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
    <xsl:if test="not(normalize-space(.) = '')">
      <section outputclass="{@kind}">
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
    <sectiondiv outputclass="{@kind}">
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
  </xsl:template>
  
  <xsl:template match="location">
    <!-- Suppress by default -->
  </xsl:template>  
  
  <xsl:template match="ref">
    <xsl:param name="wrapXref" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Assume a ref is a key reference -->
    <!-- FIXME: Some references are to things in the same result file.
                Need to distinguish these and generate same-file URL
                references.
      -->
    <xsl:choose>
      <xsl:when test="$wrapXref">
        <ph><xref keyref="{local:getKey(.)}" outputclass="{@kindref}"><xsl:apply-templates/></xref></ph>
      </xsl:when>
      <xsl:otherwise>
        <xref keyref="{local:getKey(.)}" outputclass="{@kindref}"><xsl:apply-templates/></xref>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="collaborationgraph | inheritancegraph | incdepgraph">
    <!-- FIXME: For HTML, the process generates .dot files that are
         rendered by graphviz. If those graphics are available
         can reference them here.
         
         Or we could generate SVG. But I don't think so.
         
      -->
    <section outputclass="{name(.)}" spectitle="Collaboration Graph">
      <xsl:apply-templates/>
    </section>
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
  
  <xsl:template match="para">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  
  <xsl:template match="para[linebreak]" priority="10">
    <xsl:for-each-group select="node()" group-ending-with="linebreak">
      <p><xsl:apply-templates select="current-group()"/></p>
    </xsl:for-each-group>
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
  
  <xsl:template match="linebreak"/><!-- Suppress -->
  
  <xsl:template match="simplesect[@kind = 'see']">
    <xsl:text>See </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="simplesect[@kind = 'note']">
    <note><xsl:apply-templates/></note>
  </xsl:template>
  
  <xsl:template match="simplesect[@kind = 'see']/para">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="itemizedlist">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  
  <xsl:template match="listitem">
    <li><xsl:apply-templates/></li>
  </xsl:template>
  
  <xsl:template match="emphasis">
    <i><xsl:apply-templates/></i>
  </xsl:template>  
  
  <xsl:template match="programlisting">
    <section spectitle="Program Listing">
      <codeblock><xsl:apply-templates/></codeblock>
    </section>
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