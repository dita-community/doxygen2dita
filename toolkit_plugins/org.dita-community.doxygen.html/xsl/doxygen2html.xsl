<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd" version="2.0">

  <!-- =================================
       Overrides to the base XHTML 
       transforms to handle "doxygen"
       markup in DITA topics in order to
       emulate doxygen-generated
       HTML.
       
       ================================= -->

  <xsl:template name="gen-user-header">

    <div id="top">
      <div id="titlearea">
        <table cellspacing="0" cellpadding="0">
          <tbody>
            <tr style="height: 56px;">
              <td id="projectlogo">
                <img alt="Logo" src="../resources/images/OculusLogoSmall.png"/>
              </td>
              <td style="padding-left: 0.5em;">
                <div id="projectname">Oculus SDK &#160;<span id="projectnumber">0.7.0</span>
                </div>
                <div id="projectbrief">LibOVR Reference Manual</div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <!--
      <script type="text/javascript">
        var searchBox = new SearchBox("searchBox", "search",false,'Search');
      </script>
      -->
      <div id="navrow1" class="tabs">
        <ul class="tablist">
          <li>
            <a href="index.html">
              <span>Main&#160;Page</span>
            </a>
          </li>
          <li class="current">
            <a href="annotated.html">
              <span>Data&#160;Structures</span>
            </a>
          </li>
          <li>
            <a href="files.html">
              <span>Files</span>
            </a>
          </li>
          <li>
            <div id="MSearchBox" class="MSearchBoxInactive">
              <span class="left">
                <img id="MSearchSelect" src="../resources/images/mag_sel.png"
                  onmouseover="return searchBox.OnSearchSelectShow()"
                  onmouseout="return searchBox.OnSearchSelectHide()" alt=""/>
                <input type="text" id="MSearchField" value="Search" accesskey="S"
                  onfocus="searchBox.OnSearchFieldFocus(true)"
                  onblur="searchBox.OnSearchFieldFocus(false)"
                  onkeyup="searchBox.OnSearchFieldChange(event)"/>
              </span>
              <span class="right">
                <a id="MSearchClose" href="javascript:searchBox.CloseResultsWindow()">
                  <img id="MSearchCloseImg" border="0" src="../resources/images/close.png" alt=""/>
                </a>
              </span>
            </div>
          </li>
        </ul>
      </div>
      <div id="navrow2" class="tabs2">
        <ul class="tablist">
          <li>
            <a href="annotated.html">
              <span>Data&#160;Structures</span>
            </a>
          </li>
          <li>
            <a href="classes.html">
              <span>Data&#160;Structure&#160;Index</span>
            </a>
          </li>
          <li>
            <a href="functions.html">
              <span>Data&#160;Fields</span>
            </a>
          </li>
        </ul>
      </div>
      <!-- window showing the filter options -->
      <div id="MSearchSelectWindow" onmouseover="return searchBox.OnSearchSelectShow()"
        onmouseout="return searchBox.OnSearchSelectHide()"
        onkeydown="return searchBox.OnSearchSelectKey(event)">
        <a class="SelectItem" onclick="searchBox.OnSelectItem(0)" href="javascript:void(0)"><span
            class="SelectionMark">•</span>All</a>
        <a class="SelectItem" onclick="searchBox.OnSelectItem(1)" href="javascript:void(0)"><span
            class="SelectionMark">&#160;</span>Data Structures</a>
        <a class="SelectItem" onclick="searchBox.OnSelectItem(2)" href="javascript:void(0)"><span
            class="SelectionMark">&#160;</span>Files</a>
        <a class="SelectItem" onclick="searchBox.OnSelectItem(3)" href="javascript:void(0)"><span
            class="SelectionMark">&#160;</span>Functions</a>
        <a class="SelectItem" onclick="searchBox.OnSelectItem(4)" href="javascript:void(0)"><span
            class="SelectionMark">&#160;</span>Variables</a>
        <a class="SelectItem" onclick="searchBox.OnSelectItem(5)" href="javascript:void(0)"><span
            class="SelectionMark">&#160;</span>Typedefs</a>
        <a class="SelectItem" onclick="searchBox.OnSelectItem(6)" href="javascript:void(0)"><span
            class="SelectionMark">&#160;</span>Enumerations</a>
        <a class="SelectItem" onclick="searchBox.OnSelectItem(7)" href="javascript:void(0)"><span
            class="SelectionMark">&#160;</span>Enumerator</a>
        <a class="SelectItem" onclick="searchBox.OnSelectItem(8)" href="javascript:void(0)"><span
            class="SelectionMark">&#160;</span>Macros</a>
        <a class="SelectItem" onclick="searchBox.OnSelectItem(9)" href="javascript:void(0)"><span
            class="SelectionMark">&#160;</span>Pages</a>
      </div>
    </div>
  </xsl:template>

  <!-- start Include -->
  <xsl:template match="*[@outputclass = 'includes']">
    <xsl:variable name="keyref" select="xref/@keyref"/>
    <code>#include &lt;<a class="el" href="{$keyref}_source.html"><xsl:value-of select="xref/text()"/></a>&gt;</code>        
  </xsl:template>
  
  <!-- end Include -->  


  <!-- start Public Member Functions -->
  <xsl:template match="*[@outputclass = ('function')]/sectiondiv[@outputclass = ('memberdefinition')]">    
    <a class="el" href="#a4c4152d07f41fc02cc694c2a7447fc2c">
      <xsl:value-of select="*[@outputclass='name']/text()"/>
    </a> 
    <xsl:value-of select="*[@outputclass='argsstring']/text()"/>
    
    <div class="mdescRight">&lt;  <a href="#a4c4152d07f41fc02cc694c2a7447fc2c">More...</a><br/></div>
  </xsl:template>
  
  <xsl:template match="*[@outputclass = ('function')]/sectiondiv[@outputclass = 'briefdescription']" />    
  <xsl:template match="*[@outputclass = ('function')]/sectiondiv[@outputclass = 'parameters']" />
  <xsl:template match="*[@outputclass = ('function')]/sectiondiv[@outputclass = 'detaileddescription']" />       
  <!-- end Public Member Functions -->


  <!-- start Data Fields -->
  <xsl:template
    match="//section[@outputclass = ('public-attrib')]/sectiondiv[@outputclass = ('memberdecls')]">
    <table class="memberdecls">
      <tbody>
        <xsl:for-each select="*[@outputclass = ('variable')]">
          <xsl:call-template name="variablediv"/>
        </xsl:for-each>
      </tbody>
    </table>
    
    <xsl:call-template name="detailedDescription"></xsl:call-template>
  </xsl:template>
  <xsl:template name="variablediv">
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
    <tr class="memdesc:a0cbc54a3238dea8110e869897b93a4b9">
      <td class="mdescLeft"/>
      <td class="mdescRight">
        <xsl:value-of select="sectiondiv[@outputclass = 'briefdescription']"/>
      </td>
    </tr>
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
  
  
  
  <xsl:template match="*[@outputclass = ('collaborationgraph')]" />


  <xsl:template match="*[contains(@class, ' topic/section' )][@outputclass = ('includes')]">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template
    match="*[contains(@class, ' topic/section' )]
    [tokenize(@outputclass, ' ') = ('declSummary', 'struct')]">
    <!-- Literal class values are taken from doxygen-generated HTML -->
    <table class="memberdecls">
      <tbody>
        <tr class="memitem:">
          <td class="memItemLeft">
            <xsl:apply-templates
              select="*[contains(@class, ' topic/sectiondiv ')]
              [@outputclass = 'kind']"
            />
          </td>
          <td class="memItemRight">
            <xsl:apply-templates
              select="*[contains(@class, ' topic/sectiondiv ')]
              [@outputclass = 'name']"/>
            <div class="moreinfo">
              <xsl:apply-templates select="*[contains(@class, ' topic/xref ')]"/>
            </div>
          </td>
        </tr>
        <tr class="memdesc:">
          <td class="mdescLeft">&#xa0;</td>
          <td class="mdescRight">
            <xsl:apply-templates
              select="*[contains(@class, ' topic/sectiondiv ')]
              [@outputclass = 'briefdescription']"/>
          </td>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'name']">
    <b>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

</xsl:stylesheet>
