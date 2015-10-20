<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
  <xsl:template mode="generateKeyDefinitions" match="doxygenindex">
    <!-- No keydefs generated at this time. -->
    <!-- Keys are defined on navigation topicrefs and all topics
         are included somewhere in the navigation structure. 
      -->
  </xsl:template>
  
</xsl:stylesheet>