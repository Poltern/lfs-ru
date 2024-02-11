<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

  <!-- Second level chunked output template.
       Sets global params and include customized elements templates. -->

  <!-- Upstream XHTML presentation templates -->
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"/>

  <xsl:param name="chunker.output.method" select="'xml'"/>
  <xsl:param name="chunker.output.encoding" select="'UTF-8'"/>
  <xsl:param name="chunker.output.media-type" select="'application/xhtml+xml'"/>
  <xsl:param name="chunker.output.doctype-public" select="'-//W3C//DTD XHTML 1.0 Strict//EN'"/>
  <xsl:param name="chunker.output.doctype-system" select="'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'"/>
  <xsl:param name="chunker.output.omit-xml-declaration" select="'yes'"/>
  <xsl:param name="chunker.output.indent" select="'no'"/>

  <!-- Including our customized elements templates -->
  <xsl:include href="common.xsl"/>
  <xsl:include href="xhtml/lfs-admon.xsl"/>
  <xsl:include href="xhtml/lfs-mixed.xsl"/>
  <xsl:include href="xhtml/lfs-sections.xsl"/>
  <xsl:include href="xhtml/lfs-titles.xsl"/>
  <xsl:include href="xhtml/lfs-toc.xsl"/>
  <xsl:include href="xhtml/lfs-xref.xsl"/>

  <xsl:param name="html.stylesheet" select="'stylesheets/lfs.css'"/>
  <!-- Print CSS Stylesheet -->
  <!-- The original template is in {docbook-xsl}/xhtml/docbook.xsl -->
  <xsl:template name='user.head.content'>
    <link rel="stylesheet" href="../stylesheets/lfs-print.css" type="text/css" media="print"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  </xsl:template>

  <!-- Drop some unwanted style attributes -->
  <xsl:param name="ulink.target" select="''"/>
  <xsl:param name="css.decoration" select="0"/>

  <!-- Control generation of ToCs and LoTs -->
  <xsl:param name="generate.toc">
    book      toc,title
    preface   toc
    part      toc
    chapter   toc
    appendix  nop
    sect1     nop
    sect2     nop
    sect3     nop
    sect4     nop
    sect5     nop
    section   nop
  </xsl:param>

  <!-- How deep should recursive sections appear in the TOC? -->
  <xsl:param name="toc.section.depth">1</xsl:param>

  <!-- How deep, at most, should each TOC be? -->
  <xsl:param name="toc.max.depth">3</xsl:param>

</xsl:stylesheet>
