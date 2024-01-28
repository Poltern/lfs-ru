<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

    <!-- LFS top-level no-chunk templates. -->
  <xsl:import href="lfs-xsl/nochunks.xsl"/>

    <!-- The LFS book type to be processed (lfs, blfs, clfs, or hlfs) -->
  <xsl:param name="book-type">lfs</xsl:param>

</xsl:stylesheet>
