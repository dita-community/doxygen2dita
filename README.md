# doxygen2dita
Open Toolkit plugins for converting Doxygen XML to DITA maps and topics

NOTE: Setting up proper Ant scripts to run the doxygen2dita.xsl transform is TBD. For now use OxygenXML or 
equivalent to run the transform.

NOTE: The doxygen-html plugin has only been tested with the 1.8.5 OT but it will probably work fine with the 2.x OT (although it's possible 
it overrides something that isn't in the 2.x version of the XHTML transform).

To generate DITA from Doxygen XML do the following:

1. Use Doxygen to generate XML output. This produces a set of XML files. The root file is index.xml.
2. Apply the org.dita-community.doxygen2dita/xsl/doxygen2dita.xsl transform to the index.xml file (e.g., using Oxygen via an XSLT
transformation scenario. The result will be a root DITA map and topics reflecting the top-level compound elements (files, etc.).

To produce Doxygen-style HTML output do the following:

1. Deploy the org.dita-community.doxygen.html plugin to the Open Toolkit.
2. Apply the transformation type "doxygen-html" to the root map

The plugin includes the Doxygen-provided CSS and Javascript as a convenience. 
