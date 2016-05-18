<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd" version="2.0">

  <!-- =====================================================================================
       Top-level XSLT to generate Doxygen-style HTML from DITA where the DITA reflects
       Doxygen-specific @outputclass values and/or specializations.
       
       This mostly just overrides base templates. It is structured as a separate transformation
       type so that it doesn't globally override normal HTML output.
       
       Copyright (c) 2015, 2016 DITA Community
       ====================================================================================== -->
  
  <!-- Complete override of this template from dita2htmlImpl.xsl 
  
       This mode is only used for top-level topics.
  -->
  <xsl:template match="*" mode="chapterBody">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] chapterBody: <xsl:value-of select="@outputclass"/></xsl:message>
      <xsl:message> + [DEBUG] chapterBody: File: <xsl:value-of select="document-uri(root(.))"/></xsl:message>
    </xsl:if>
    
    <body>
      <!-- Already put xml:lang on <html>; do not copy to body with commonattributes -->
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass" mode="add-ditaval-style"/>
      <!--output parent or first "topic" tag's outputclass as class -->
      <xsl:if test="@outputclass">
        <xsl:attribute name="class"><xsl:value-of select="@outputclass" /></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="." mode="addAttributesToBody"/>
      <xsl:call-template name="setidaname"/>
      <xsl:value-of select="$newline"/>
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
      <xsl:call-template name="gen-user-header"/>  <!-- include user's XSL running header here -->
      <xsl:call-template name="processHDR"/>
      <xsl:if test="$INDEXSHOW = 'yes'">
        <xsl:apply-templates select="/*/*[contains(@class, ' topic/prolog ')]/*[contains(@class, ' topic/metadata ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')] |
          /dita/*[1]/*[contains(@class, ' topic/prolog ')]/*[contains(@class, ' topic/metadata ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')]"/>
      </xsl:if>
      <div class="headertitle">
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </div>
      <div class="contents">
        <xsl:apply-templates select="(*[contains(@class, ' topic/abstract ')] |
          *[contains(@class, ' topic/shortdesc ')]),
          *[contains(@class, ' topic/body ')]">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
        <xsl:call-template name="gen-endnotes"/>    <!-- include footnote-endnotes -->
      </div>
      
      <xsl:call-template name="gen-user-footer"/> <!-- include user's XSL running footer here -->
      <xsl:call-template name="processFTR"/>      <!-- Include XHTML footer, if specified -->
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
    </body>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>
  
  
  
  <!-- Generate "more..." link to the main part of the topic's output. -->
  <xsl:template match="*['compounddef' = tokenize(@outputclass, ' ')]/*[contains(@class, ' topic/shortdesc ')]" 
    mode="outofline">
    <p>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
      <a href="#details">More...</a>
    </p><xsl:text>&#x0a;</xsl:text>
  </xsl:template>
  
  <!-- start Include -->
  <xsl:template match="*[contains(@class, ' topic/ph ')][@outputclass = 'includes']">
    <xsl:variable name="keyref" select="xref/@keyref"/>
    <code><xsl:apply-templates mode="#current"/></code>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/section ')][@outputclass = 'includes']">
    <div class="textblock">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <!-- end Include -->  
  
  <!-- Handle nested topics that require special output -->
  
  <xsl:template match="*[contains(@class, ' topic/topic ')]['detaileddescription' = tokenize(@outputclass, ' ')]">
    <a id="details" name="details">&#xa0;</a>
    <xsl:next-match/>
  </xsl:template>
  
  
  <!-- Default processing for nested topics topics. 
  
       There is no containing wrapper for topics in the Doxygen
       HTML, just an a element, then the title container, then
       any contents.
  -->
  <xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/topic ')]" priority="0">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:apply-templates select="*[contains(@class, ' topic/title ')]">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    <div class="textblock">
      <xsl:apply-templates select="*[contains(@class, ' topic/body ')]">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </div>
    <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template match="/*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]">
     <h2 class="groupheader"><xsl:apply-templates/></h2> 
   </xsl:template>
  
  
  <xsl:template match="*[contains(@class, ' topic/topic ')][('declSummary') = tokenize(@outputclass, ' ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- Declaration summary output puts everything in a table, including the topic title,
         so we basically skip right to the topic body processing.
      -->
    <xsl:apply-templates select="*[contains(@class, ' topic/body ')]"
      mode="#current"
    />
    <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]" >
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- Handle topics that contain declaration summaries, which need to be rendered as tables 
  
       This is based on the topic/body template in dita2htmlImpl.xsl. It overrides
       the handling of the body content. All the rest is unchanged.
  -->
  <xsl:template match="*[contains(@class, ' reference/refbody ')]
    [*[contains(@class, ' topic/section')]['declSummary' = tokenize(@outputclass, ' ')]]" name="topic.body">
    <div>
      <xsl:call-template name="commonattributes"/>
      <xsl:call-template name="setidaname"/>
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
      
      <xsl:call-template name="makeDeclSummaryTable">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
      </xsl:call-template>
      
      
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
    </div><xsl:value-of select="$newline"/>
  </xsl:template>
  
  <xsl:template name="makeDeclSummaryTable">
    <!-- The table markup details are taken directly from the Doxygen-generated 
         HTML.
      -->
    <table class="memberdecls">
      <tbody>
        <xsl:apply-templates select="../*[contains(@class, ' topic/title ')]"
          mode="makeDeclSummaryTable"
        />
        <xsl:apply-templates mode="makeDeclSummaryTable"/>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template mode="makeDeclSummaryTable" match="*[contains(@class, ' topic/title ')]">
    
    <!-- The number of ancestor topics, including the one containing the title. 
    
         For topics in the summary area, the depth will always be at least 2 since there
         is always a root parent topic.
    -->
    <xsl:variable name="depth" as="xs:integer" 
      select="count(ancestor::*[contains(@class, ' topic/topic ')])" />
    
    <tr class="heading">
      <td colspan="2">
        <xsl:element name="h{$depth}">
          <xsl:attribute name="class" select="'groupheader'"/>
          <xsl:apply-templates/>
        </xsl:element>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template mode="makeDeclSummaryTable"
    match="*[contains(@class, ' topic/section' )]
    [tokenize(@outputclass, ' ') = ('declSummary', 'struct')]">
    
    <!-- This template handles different kinds of things so the apply-templates
         reflect the union of different detailed elements that can occur
         in differnt kinds and need to be reflected in the summary table.
      -->
    <!-- Literal class values are taken from doxygen-generated HTML -->
    <tr class="memitem:">
      <td class="memItemLeft">
        <xsl:apply-templates
          select="*[contains(@class, ' topic/sectiondiv ')]
          [@outputclass = 'kind']"
        />
        <xsl:apply-templates
          select="*[contains(@class, ' topic/sectiondiv ')]
          [@outputclass = 'type']"
        />
      </td>
      <td class="memItemRight">
        <xsl:apply-templates
          select="*[contains(@class, ' topic/sectiondiv ')]
          [@outputclass = 'name']"/>       
        <xsl:apply-templates
          select="*[contains(@class, ' topic/sectiondiv ')]
          [@outputclass = 'parameters']"/>
        <xsl:apply-templates
          select="*[contains(@class, ' topic/sectiondiv ')]
          [@outputclass = 'initializer']"/>
        <xsl:apply-templates
          select="*[contains(@class, ' topic/sectiondiv ')]
          [@outputclass = 'argsstring']"/>
        <xsl:apply-templates
          select="*[contains(@class, ' topic/sectiondiv ')]
          [@outputclass = 'enumvalues']"/>
      </td>
    </tr>
    <xsl:if test="not(matches(normalize-space(sectiondiv[@outputclass = 'briefdescription']), '^\s*$'))">
      <tr class="memdesc:">
        <td class="mdescLeft">&#xa0;</td>
        <td class="mdescRight">
          <xsl:apply-templates mode="#current"
            select="*[contains(@class, ' topic/sectiondiv ')]
            [@outputclass = 'briefdescription']"/>
          <xsl:apply-templates select="*[contains(@class, ' topic/xref ')]"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'parameters']">
    <xsl:text>(</xsl:text><xsl:apply-templates/><xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'param']">
    <xsl:if test="preceding-sibling::*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'param']">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'initializer']">
    <xsl:text>&#xa0;&#xa0;&#xa0;</xsl:text><xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'declname']">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'argsstring']">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template priority="10"
    match="*[contains(@class, ' topic/section ')]['function' = tokenize(@outputclass, ' ')]/
    *[contains(@class, ' topic/sectiondiv ')][('argsstring', 'kind') = tokenize(@outputclass, ' ')]">
    <!-- Suppress argsstring for functions as the params sectiondiv has the same information
         with hyperlinks.
      -->
    
    <!-- Suppress type for function as it's not used in the output -->
  </xsl:template>
  
  
  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'type']">
    <xsl:text>&#x0a;</xsl:text><xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'kind']">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'enumvalues']">
    <xsl:text>{</xsl:text><br/>
    <xsl:text>&#xa0;&#xa0;</xsl:text><!-- Indent the first line by two spaces -->
    <!-- Avoid literal commas in the source: -->
    <xsl:apply-templates select="*[contains(@class, ' topic/ph ')][@outputclass = 'enumvalue']"/>
    <br/><xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/ph ')][@outputclass = 'enumvalue']">
    <!-- Pad on left and break every 4th item -->
    <xsl:apply-templates/>
    <xsl:if test="following-sibling::*[contains(@class, ' topic/ph ')][@outputclass = 'enumvalue']">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:if test="following-sibling::*[contains(@class, ' topic/ph ')][@outputclass = 'enumvalue'] and
      ((count(preceding-sibling::*[contains(@class, ' topic/ph ')][@outputclass = 'enumvalue']) + 1) mod 4) = 0">
      <br/>
      <xsl:text>&#xa0;&#xa0;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/ph ')][@outputclass = 'enumvalue']/
                         *[contains(@class, ' topic/ph ')][@outputclass = 'name']">
    <b><xsl:apply-templates/></b>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/ph ')][@outputclass = 'enumvalue']/
    *[contains(@class, ' topic/ph ')][@outputclass = 'initializer']">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template mode="makeDeclSummaryTable" match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'briefdescription']">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- Do not generate a <div> in this context -->
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] makeDeclSummaryTable: topic/sectiondiv, <xsl:value-of select="@outputclass"/> </xsl:message>
    </xsl:if>
    
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template mode="makeDeclSummaryTable" match="*[contains(@class, ' topic/sectiondiv ')]/*[contains(@class, ' topic/p ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] makeDeclSummaryTable: topic/p </xsl:message>
    </xsl:if>
    <!-- Do not generate a <p> in this context -->
    <xsl:apply-templates/>
  </xsl:template>
  

  <!-- start Public Member Functions -->
  <xsl:template match="*[@outputclass = ('function')]/sectiondiv[@outputclass = ('memberdefinition')]">    
    <a class="el" href="#a4c4152d07f41fc02cc694c2a7447fc2c">
      <xsl:value-of select="*[@outputclass='name']/text()"/>
    </a> 
    <xsl:value-of select="*[@outputclass='argsstring']/text()"/>
    
    <div class="mdescRight">&lt;  <a href="#a4c4152d07f41fc02cc694c2a7447fc2c">More...</a><br/></div>
  </xsl:template>
  
  <xsl:template match="*[@outputclass = ('function')]/sectiondiv[@outputclass = 'briefdescription']" />    
<!--  <xsl:template match="*[@outputclass = ('function')]/sectiondiv[@outputclass = 'parameters']" />-->
  <xsl:template match="*[@outputclass = ('function')]/sectiondiv[@outputclass = 'detaileddescription']" />       
  <!-- end Public Member Functions -->


  <!-- start Data Fields -->
  <xsl:template
    match="//section[@outputclass = ('public-attrib')]/sectiondiv[@outputclass = ('memberdecls')]">
    <table class="memberdecls">
      <tbody>
        <xsl:apply-templates select="*[@outputclass = ('variable')]" mode="variablediv"/>
      </tbody>
    </table>
    
    <xsl:call-template name="detailedDescription"></xsl:call-template>
  </xsl:template>
  
  <xsl:template mode="variablediv" match="*[@outputclass = ('variable')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] variablediv: Handling <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>
    <tr class="memitem:a0cbc54a3238dea8110e869897b93a4b9">
      <xsl:choose>
        <xsl:when test="sectiondiv/sectiondiv[@outputclass = 'type']/xref">
          <xsl:variable name="keyref"
            select="sectiondiv/sectiondiv[@outputclass = 'type']/xref/@keyref"/>
          <td class="memItemLeft" align="right" valign="top">
            <a class="anchor" id="a0cbc54a3238dea8110e869897b93a4b9"/>
            <a class="el" href="{$keyref}.html">
              <xsl:value-of select="sectiondiv/sectiondiv/*[@outputclass = 'compound']/text()"/>
            </a>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td class="memItemLeft" align="right" valign="top">
            <xsl:value-of select="sectiondiv/sectiondiv[@outputclass = 'type']/text()"/>
          </td>
        </xsl:otherwise>
      </xsl:choose>
      <td class="memItemRight" valign="bottom">
        <a class="el" href="structovr_d3_d11_texture_data.html#a0cbc54a3238dea8110e869897b93a4b9">
          <xsl:value-of select="sectiondiv/*[@outputclass = 'name']/text()"/>
        </a>
      </td>
    </tr>
    <xsl:if test="not(matches(normalize-space(sectiondiv[@outputclass = 'briefdescription']), '^\s*$'))">
      <!-- Don't put out the row if there's no text. -->
      <tr class="memdesc:a0cbc54a3238dea8110e869897b93a4b9">
        <td class="mdescLeft">&#xa0;</td>
        <td class="mdescRight">
          <xsl:apply-templates  
            select="sectiondiv[@outputclass = 'briefdescription']"/>
        </td>
      </tr>
    </xsl:if>
    <tr class="separator:a0cbc54a3238dea8110e869897b93a4b9">
      <td class="memSeparator" colspan="2"/>
    </tr>
  </xsl:template>
  <!-- end Data Fields -->
  
  
  <!-- start Detailed Description -->
  <xsl:template name="detailedDescription">
    <h2 class="groupheader">Detailed Description</h2>
    
    <xsl:call-template name="memberFunctionDocumentation"></xsl:call-template>    
  </xsl:template>  
  <!-- end Detailed Description -->


  <!-- start Member Function Documentation -->
  <xsl:template name="memberFunctionDocumentation">
    <h2 class="groupheader">Member Function Documentation</h2>
  </xsl:template>
  <!-- end Member Function Documentation -->
  
  
  <!-- ========================================================
       Detailed documentation topics
       ======================================================== -->
  
  <!-- Child reference entries within groups within the main reference item.
    
       These topics should be member definitions.
       
    -->
  <xsl:template match="/*[contains(@class, ' reference/reference ')]/*[contains(@class, ' reference/reference ')]/
    *[contains(@class, ' reference/reference ')][('typedef', 'define', 'enum', 'function') = tokenize(@outputclass, ' ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <a class="anchor" id="{@id}">&#xa0;</a>
    <div class="memitem">
      <div class="memproto">
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="memproto">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </div>
      <div class="memdoc">
        <xsl:apply-templates select="*[contains(@class, ' topic/shortdesc ')],*[contains(@class, ' topic/body ')]"
          mode="memitem"
        />
      </div>
    </div>
    
    <!-- There don't appear to ever be topics within member items but you never know. -->
    <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="memproto" match="*[contains(@class, ' topic/title ')]">
    <table class="memname">
      <tbody>
        <tr>
          <!-- FIXME: This is not sufficient to match the Doxygen result but will do for now. -->
          <td class="memname"><xsl:apply-templates/></td>
        </tr>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template mode="memproto" match="*[contains(@class, ' topic/topic ')]['function' = tokenize(@outputclass, ' ')]/*[contains(@class, ' topic/title ')]"
      priority="10"
    >
    <table class="memname">
      <tbody>
        <!-- The function signature is organized into multiple rows, one for each parameter --> 
        <tr>
          <td class="memname">
            <xsl:apply-templates select="ph[@outputclass = 'type']"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="ph[@outputclass = 'name']"/>
          </td>
          <td><xsl:text>(</xsl:text></td>
          <xsl:variable name="firstParam" as="element()?"
            select="(ph[@outputclass = 'param'])[1]"
          />
          <xsl:choose>
            <xsl:when test="$firstParam and $firstParam/following-sibling::ph[@outputclass = 'param']">
              <xsl:apply-templates select="$firstParam" mode="#current"/>
            </xsl:when>
            <xsl:when test="$firstParam">
              <!-- Put closing ")" in the last cell of the table in this row. -->
              <xsl:apply-templates mode="#current" select="$firstParam/ph[@outputclass = 'type']"/>
              <td class="paramname">
                <xsl:apply-templates select="$firstParam/ph[@outputclass = 'declname']"/>
                <!-- Note space before parenthesis -->
                <xsl:text> )</xsl:text>
              </td>
              
            </xsl:when>
            <xsl:otherwise>
              <td>&#xa0;</td>
              <td><xsl:text>)</xsl:text></td>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
        <xsl:for-each select="ph[@outputclass = 'param']">
          <xsl:choose>
            <xsl:when test="position() = 1">
              <!-- SKip, in first row -->
            </xsl:when>
            <xsl:otherwise>
              <tr>
                <td class="paramkey">&#xa0;</td>
                <td>&#xa0;</td>
                <xsl:apply-templates select="." mode="#current"/>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <xsl:if test="count(ph[@outputclass = 'param']) gt 1">
          <tr>
            <td>&#xa0;</td>
            <td><xsl:text>)</xsl:text></td>
            <td>&#xa0;</td>
            <td>&#xa0;</td>
          </tr>
        </xsl:if>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template mode="memproto" match="ph[@outputclass = 'param']">
    <xsl:apply-templates mode="#current" select="ph"/>
  </xsl:template>

  <xsl:template mode="memproto" match="ph[@outputclass = 'param']/ph[@outputclass = 'type']">
    <td class="paramtype"><xsl:apply-templates/></td>
  </xsl:template>

  <xsl:template mode="memproto" match="ph[@outputclass = 'param']/ph[@outputclass = 'declname']">
    <td class="paramname">
      <xsl:apply-templates/>
      <xsl:if test="../following-sibling::ph[@outputclass = 'param']">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </td>
  </xsl:template>
  
  <xsl:template mode="memitem" match="*[contains(@class, ' topic/body ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] memitem: topic/body</xsl:message>
    </xsl:if>
    
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template mode="memitem" match="*[contains(@class, ' topic/section ')][@spectitle = 'Parameters']">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] section, spectitle="Parameters"</xsl:message>
    </xsl:if>
    
    <dl class="params">
      <dt>Parameters</dt>
      <dd>
        <xsl:apply-templates mode="#current"/>
      </dd>
    </dl>
  </xsl:template>
  
  <!-- Parameter list in default mode, which should apply to detailed
       descriptions for member definitions.
    -->
  <xsl:template mode="memitem" match="*[contains(@class, ' pr-d/parml ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] memitem: <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>
    
    <table class="params">
      <tbody>
        <xsl:apply-templates select="*[contains(@class, ' pr-d/plentry ')]" mode="#current"/>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template mode="memitem" match="*[contains(@class, ' pr-d/plentry ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] memitem: <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>

    <tr>
      <td class="paramdir"><xsl:value-of select="if (pt/parmname/@outputclass = 'direction_out') then '[out]' else '[in]'"/></td>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  
  
  <xsl:template match="*[contains(@class, ' pr-d/pt ')]">
    <td class="paramname"><xsl:apply-templates/></td>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' pr-d/pd ')]">
    <td><xsl:apply-templates 
       select="*[contains(@class, ' topic/p ')][1]/node(), 
                *[contains(@class, ' topic/p ')][position() gt 1]"/></td>
  </xsl:template>
  
  <xsl:template mode="memitem" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] memitem: Fallback: <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>
    
    <xsl:apply-templates select="."/>
  </xsl:template>
  
  
  
  <xsl:template match="*[@outputclass = ('collaborationgraph')]" />

  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'name']">
    <!-- FIXME: Need to generate link to the corresponding definition of the thing. -->
    <b>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/pre ')]" name="topic.pre" mode="#default pre-fmt">
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
    <xsl:call-template name="spec-title-nospace"/>
    <pre>
    <xsl:call-template name="commonattributes"/>
    <xsl:attribute name="class" select="string-join(('fragment', name(.), @outputclass), ' ')"/>
    <xsl:call-template name="setscale"/>
    <xsl:call-template name="setidaname"/>
    <xsl:apply-templates/>
  </pre>
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
    <xsl:value-of select="'&#x0a;'"/>
  </xsl:template>
</xsl:stylesheet>
