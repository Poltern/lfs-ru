<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE xsl:stylesheet [
 <!ENTITY % general-entities SYSTEM "../general.ent">
  %general-entities;
]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="text"/>

    <!-- Allow select the dest dir at runtime -->
  <xsl:param name="dest.dir">
    <xsl:value-of select="concat('/srv/www/', substring-after('&patches-root;', 'https://'))"/>
  </xsl:param>

  <xsl:template match="/">
    <xsl:text>#! /bin/bash

function copy
{
  cp $1 $2 >>copyerrs 2>&amp;1
}

umask 002

# Create dest.dir if it doesn't exist
# Remove old patches
# Copy the patches
# Ensure correct ownership
install -d -m 775 -g lfswww </xsl:text>
    <xsl:value-of select="$dest.dir"/>
    <xsl:text> &amp;&amp;
cd </xsl:text>
    <xsl:value-of select="$dest.dir"/>
    <xsl:text> &amp;&amp;
rm -f *.patch copyerrs &amp;&amp;

</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>
chgrp lfswww *.patch &amp;&amp;
if [ `wc -l copyerrs | sed 's/ *//' | cut -f1 -d' '` -gt 0 ]; then
  mail -s "Missing LFS patches" lfs-book@lists.linuxfromscratch.org &lt; copyerrs
fi

exit
</xsl:text>
  </xsl:template>

  <xsl:template match="//text()"/>

  <xsl:template match="//ulink">
      <!-- Match only local patches links and skip duplicated URLs splitted for PDF output-->
    <xsl:if test="contains(@url, '.patch') and contains(@url, '&patches-root;')
            and not(ancestor-or-self::*/@condition = 'pdf')">
      <xsl:variable name="patch.name" select="substring-after(@url, '&patches-root;')"/>
      <xsl:variable name="cut"
              select="translate(substring-after($patch.name, '-'), '0123456789', '0000000000')"/>
      <xsl:variable name="patch.name2">
        <xsl:value-of select="substring-before($patch.name, '-')"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$cut"/>
      </xsl:variable>
      <xsl:text>copy /srv/www/www.linuxfromscratch.org/patches/downloads/</xsl:text>
      <xsl:value-of select="substring-before($patch.name2, '-0')"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="$patch.name"/>
      <xsl:text> .
</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
