<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
  <!-- =================================
       Overrides to the base XHTML 
       transforms to handle "doxygen"
       markup in DITA topics in order to
       emulate doxygen-generated
       HTML.
       
       ================================= -->
  
  
  <xsl:template match="*[contains(@class, ' topic/section' )][@outputclass = ('includes')]">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/section' )]
                        [tokenize(@outputclass, ' ') = ('declSummary', 'struct')]">
    <!-- Literal class values are taken from doxygen-generated HTML -->
    <table class="memberdecls">
      <tbody>
        <tr class="memitem">
          <td class="memItemLeft"><xsl:apply-templates select="*[contains(@class, ' topic/sectiondiv ')]
                                          [@outputclass = 'kind']"/></td>
          <td class="memItemRight"><xsl:apply-templates select="*[contains(@class, ' topic/sectiondiv ')]
                                          [@outputclass = 'name']"/>
            <div class="moreinfo">
              <xsl:apply-templates select="*[contains(@class, ' topic/xref ')]"/>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/sectiondiv ')][@outputclass = 'name']">
    <b><xsl:apply-templates/></b>
  </xsl:template>
  
  
</xsl:stylesheet>