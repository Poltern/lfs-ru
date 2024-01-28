<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

  <!-- This stylesheet fixes English punctuation in xref links
       (as was requested by the publisher) via adding @role propagation
       in xref tags.
       This hack may not work with xref flavours not used in the book.
       For other languages, just remove the xref @role attributes
       in the book XML sources and/or comment-out the inclusion of
       this file in lfs-chunked2.xsl -->

    <!-- xref:
           Added role variable and use it when calling mode xref-to.
           Also remove code for xlink:href attributes in xref elements
           since we don't use it.-->
    <!-- The original template is in {docbook-xsl}/xhtml/xref.xsl -->
  <xsl:template match="xref" name="xref">
    <xsl:param name="linkend.targets" select="key('id',@linkend)"/>
    <xsl:param name="target" select="$linkend.targets[1]"/>
      <!-- Added role variable -->
    <xsl:variable name="role" select="@role"/>
    <xsl:variable name="xrefstyle">
      <xsl:choose>
        <xsl:when test="@role and not(@xrefstyle) and $use.role.as.xrefstyle != 0">
          <xsl:value-of select="@role"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@xrefstyle"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="anchor"/>
    <xsl:variable name="content">
      <xsl:choose>
        <xsl:when test="@endterm">
          <xsl:variable name="etargets" select="key('id',@endterm)"/>
          <xsl:variable name="etarget" select="$etargets[1]"/>
          <xsl:choose>
            <xsl:when test="count($etarget) = 0">
              <xsl:message>
                <xsl:value-of select="count($etargets)"/>
                <xsl:text>Endterm points to nonexistent ID: </xsl:text>
                <xsl:value-of select="@endterm"/>
              </xsl:message>
              <xsl:text>???</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$etarget" mode="endterm"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$target/@xreflabel">
          <xsl:call-template name="xref.xreflabel">
            <xsl:with-param name="target" select="$target"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$target">
          <xsl:if test="not(parent::citation)">
            <xsl:apply-templates select="$target" mode="xref-to-prefix"/>
          </xsl:if>
          <xsl:apply-templates select="$target" mode="xref-to">
            <xsl:with-param name="referrer" select="."/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
             <!-- Propagate role -->
            <xsl:with-param name="role" select="$role"/>
          </xsl:apply-templates>
          <xsl:if test="not(parent::citation)">
            <xsl:apply-templates select="$target" mode="xref-to-suffix"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>ERROR: xref linking to </xsl:text>
            <xsl:value-of select="@linkend"/>
            <xsl:text> has no generated link text.</xsl:text>
          </xsl:message>
          <xsl:text>???</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content" select="$content"/>
    </xsl:call-template>
  </xsl:template>

    <!-- sect* mode xref-to:
           Propagate role to mode object.xref.markup (see ../lfs-common.xsl) -->
    <!-- The original template is in {docbook-xsl}/xhtml/xref.xsl -->
  <xsl:template match="section|simplesect|sect1|sect2|sect3|sect4|sect5|refsect1
                       |refsect2|refsect3|refsection" mode="xref-to">
    <xsl:param name="referrer"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="verbose" select="1"/>
    <xsl:param name="role"/>
    <xsl:apply-templates select="." mode="object.xref.markup">
      <xsl:with-param name="purpose" select="'xref'"/>
      <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
      <xsl:with-param name="referrer" select="$referrer"/>
      <xsl:with-param name="verbose" select="$verbose"/>
      <xsl:with-param name="role" select="$role"/>
    </xsl:apply-templates>
  </xsl:template>

    <!-- insert.title.markup:
           Apply the role value. -->
    <!-- The original template is in {docbook-xsl}/xhtml/xref.xsl -->
  <xsl:template match="*" mode="insert.title.markup">
    <xsl:param name="purpose"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="title"/>
    <xsl:param name="role"/>
    <xsl:choose>
      <xsl:when test="$purpose = 'xref' and titleabbrev">
        <xsl:apply-templates select="." mode="titleabbrev.markup"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$title"/>
        <xsl:value-of select="$role"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
