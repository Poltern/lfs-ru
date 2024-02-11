<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE xsl:stylesheet [
<!ENTITY lowercase "'AaÀàÁáÂâÃãÄäÅåĀāĂăĄąǍǎǞǟǠǡǺǻȀȁȂȃȦȧḀḁẚẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặBbƀƁɓƂƃḂḃḄḅḆḇCcÇçĆćĈĉĊċČčƇƈɕḈḉDdĎďĐđƊɗƋƌǅǲȡɖḊḋḌḍḎḏḐḑḒḓEeÈèÉéÊêËëĒēĔĕĖėĘęĚěȄȅȆȇȨȩḔḕḖḗḘḙḚḛḜḝẸẹẺẻẼẽẾếỀềỂểỄễỆệFfƑƒḞḟGgĜĝĞğĠġĢģƓɠǤǥǦǧǴǵḠḡHhĤĥĦħȞȟɦḢḣḤḥḦḧḨḩḪḫẖIiÌìÍíÎîÏïĨĩĪīĬĭĮįİƗɨǏǐȈȉȊȋḬḭḮḯỈỉỊịJjĴĵǰʝKkĶķƘƙǨǩḰḱḲḳḴḵLlĹĺĻļĽľĿŀŁłƚǈȴɫɬɭḶḷḸḹḺḻḼḽMmɱḾḿṀṁṂṃNnÑñŃńŅņŇňƝɲƞȠǋǸǹȵɳṄṅṆṇṈṉṊṋOoÒòÓóÔôÕõÖöØøŌōŎŏŐőƟƠơǑǒǪǫǬǭǾǿȌȍȎȏȪȫȬȭȮȯȰȱṌṍṎṏṐṑṒṓỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợPpƤƥṔṕṖṗQqʠRrŔŕŖŗŘřȐȑȒȓɼɽɾṘṙṚṛṜṝṞṟSsŚśŜŝŞşŠšȘșʂṠṡṢṣṤṥṦṧṨṩTtŢţŤťŦŧƫƬƭƮʈȚțȶṪṫṬṭṮṯṰṱẗUuÙùÚúÛûÜüŨũŪūŬŭŮůŰűŲųƯưǓǔǕǖǗǘǙǚǛǜȔȕȖȗṲṳṴṵṶṷṸṹṺṻỤụỦủỨứỪừỬửỮữỰựVvƲʋṼṽṾṿWwŴŵẀẁẂẃẄẅẆẇẈẉẘXxẊẋẌẍYyÝýÿŸŶŷƳƴȲȳẎẏẙỲỳỴỵỶỷỸỹZzŹźŻżŽžƵƶȤȥʐʑẐẑẒẓẔẕẕ'">
<!ENTITY uppercase "'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDDDDDDEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEFFFFFFGGGGGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIJJJJJJKKKKKKKKKKKKKKLLLLLLLLLLLLLLLLLLLLLLLLLLMMMMMMMMMNNNNNNNNNNNNNNNNNNNNNNNNNNNOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOPPPPPPPPQQQRRRRRRRRRRRRRRRRRRRRRRRSSSSSSSSSSSSSSSSSSSSSSSTTTTTTTTTTTTTTTTTTTTTTTTTUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUVVVVVVVVWWWWWWWWWWWWWWWXXXXXXYYYYYYYYYYYYYYYYYYYYYYYZZZZZZZZZZZZZZZZZZZZZ'">
<!ENTITY primary   'normalize-space(concat(primary/@sortas, primary[not(@sortas) or @sortas = ""]))'>
<!ENTITY secondary 'normalize-space(concat(secondary/@sortas, secondary[not(@sortas) or @sortas = ""]))'>
<!ENTITY scope     "count(ancestor::node()|$scope) = count(ancestor::node())">
<!ENTITY section   "(ancestor-or-self::set |ancestor-or-self::book |ancestor-or-self::part |ancestor-or-self::reference |ancestor-or-self::partintro |ancestor-or-self::chapter |ancestor-or-self::appendix |ancestor-or-self::preface |ancestor-or-self::article |ancestor-or-self::section |ancestor-or-self::sect1 |ancestor-or-self::sect2 |ancestor-or-self::sect3 |ancestor-or-self::sect4 |ancestor-or-self::sect5 |ancestor-or-self::refentry |ancestor-or-self::refsect1 |ancestor-or-self::refsect2 |ancestor-or-self::refsect3 |ancestor-or-self::simplesect |ancestor-or-self::bibliography |ancestor-or-self::glossary |ancestor-or-self::index |ancestor-or-self::webpage)[last()]">
<!ENTITY section.id "generate-id(&section;)">
<!ENTITY sep '" "'>
]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

  <!-- Change the file name of the index page from the default ix01.html.
       There is no upstream template with match="index", only a global
       match="*", thus the following is enough to override the index
       filename. -->

  <xsl:template match="index" mode="recursive-chunk-filename">
    <xsl:text>longindex.html</xsl:text>
  </xsl:template>

  <!-- The original template in {docbook-xsl}/xhtml/autoidx.xsl has
  a bug (https://github.com/docbook/xslt10-stylesheets/issues/239)
  that generates a <div> with a wrong xmlns:xlink attribute. So copy it
  here where the bug does not occur, (and simplify it a lot).-->

  <xsl:template name="generate-basic-index">
    <xsl:param name="scope" select="NOTANODE"/>

    <xsl:variable name="terms" select="//indexterm
      [count(.|key('letter',
                   translate(substring(&primary;, 1, 1),
                             &lowercase;,
                             &uppercase;
                            )
                  ) [&scope;][1]) = 1]"/>
    <div class="index">
      <xsl:apply-templates select="$terms" mode="index-div-basic">
        <xsl:with-param name="position" select="position()"/>
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:sort select="translate(&primary;, &lowercase;, &uppercase;)"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <!-- Divisions:
       Override the default division titles, translating them from the default
       'A', 'B', etc. to 'Packages', 'Programs', etc.
       Add gentext support to division titles.
       Use h2 for division titles instead of the default h3.
       Change main listings from dl to ul format.
       The original template is in {docbook-xsl}/xhtml/autoidx.xsl -->

  <xsl:template match="indexterm" mode="index-div-basic">
    <xsl:param name="scope" select="."/>
    <xsl:variable name="key" select="translate(substring(&primary;, 1, 1),&lowercase;,&uppercase;)"/>
    <xsl:variable name="divtitle" select="translate($key, &lowercase;, &uppercase;)"/>
    <!-- Make sure that we don't generate a div if there are no terms in scope
   -->
    <xsl:if test="key('letter', $key)[&scope;] [count(.|key('primary', &primary;)[&scope;][1]) = 1]">
      <xsl:if test="contains(concat(&lowercase;, &uppercase;), $key)">
        <h2>
          <xsl:choose>
            <xsl:when test="$divtitle = 'A'">
              <a id="package-index" name="package-index"/>
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">Packages</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$divtitle = 'B'">
              <a id="program-index" name="program-index"/>
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">Programs</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$divtitle = 'C'">
              <a id="library-index" name="library-index"/>
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">Libraries</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$divtitle = 'D'">
              <xsl:choose>
                <xsl:when test="$book-type = 'blfs'">
                  <a id="kernel-config-index" name="kernel-config-index"/>
                  <xsl:call-template name="gentext">
                    <xsl:with-param name="key">Kernel Configuration</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <a id="scripts-index" name="scripts-index"/>
                  <xsl:call-template name="gentext">
                    <xsl:with-param name="key">Scripts</xsl:with-param>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$divtitle = 'E'">
              <xsl:choose>
                <xsl:when test="$book-type = 'blfs'">
                  <a id="config-file-index" name="config-file-index"/>
                  <xsl:call-template name="gentext">
                    <xsl:with-param name="key">Configuration Files</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <a id="other-index" name="other-index"/>
                  <xsl:call-template name="gentext">
                    <xsl:with-param name="key">Others</xsl:with-param>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$divtitle = 'F'">
                <a id="bootscript-index" name="bootscript-index"/>
                <xsl:call-template name="gentext">
                  <xsl:with-param name="key">Bootscripts</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$divtitle = 'G'">
              <a id="other-index" name="other-index"/>
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">Others</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$divtitle"/>
            </xsl:otherwise>
          </xsl:choose>
        </h2>
      </xsl:if>
      <ul>
      <xsl:apply-templates select="key('letter', $key)[count(ancestor::node()|$scope) = count(ancestor::node())][count(.|key('primary', normalize-space(concat(primary/@sortas, &quot; &quot;, primary)))[count(ancestor::node()|$scope) = count(ancestor::node())][1])=1]" mode="index-primary">
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:sort select="translate(&primary;, &lowercase;, &uppercase;)"/>
      </xsl:apply-templates>
      </ul>
    </xsl:if>
  </xsl:template>

  <!-- Primary items:
       Place term and separator into strong tags.
       Place target links into a div.
       Change main listings from dl to ul format.
       Removed code for unused see and sealso children.
       The original template is in {docbook-xsl}/xhtml/autoidx.xsl -->
  <xsl:template match="indexterm" mode="index-primary">
    <xsl:param name="scope" select="."/>
    <xsl:variable name="key" select="normalize-space(concat(primary/@sortas, &quot; &quot;, primary))"/>
    <xsl:variable name="refs" select="key('primary', $key)[count(ancestor::node()|$scope) = count(ancestor::node())]"/>
    <li>
      <strong class="item">
        <xsl:value-of select="primary"/>
        <xsl:text>: </xsl:text>
      </strong>
      <span class='indexref'>
        <xsl:for-each select="$refs[generate-id() = generate-id(key('primary-section',concat($key, &sep;, &section.id;))[&scope;][1])]">
        <!--<xsl:for-each select="$refs[not(see) and not(secondary)][count(ancestor::node()|$scope) = count(ancestor::node()) = 0]">-->
          <xsl:apply-templates select="." mode="reference">
            <xsl:with-param name="scope" select="$scope"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </span>
      <xsl:if test="$refs/secondary">
        <ul>
          <xsl:apply-templates select="$refs[secondary and count(.|key('secondary', concat($key, &quot; &quot;, normalize-space(concat(secondary/@sortas, &quot; &quot;, secondary))))[count(ancestor::node()|$scope) = count(ancestor::node()) ][1]) = 1]" mode="index-secondary">
            <xsl:with-param name="scope" select="$scope"/>
            <xsl:sort select="translate(&secondary;, &lowercase;, &uppercase;)"/>
          </xsl:apply-templates>
         </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <!-- Secondary items:
       Place term and separator into strong tags.
       Place target links into a div.
       Change main listings from dl to ul format.
       Removed code for unused tertiary, see and sealso children.
       The original template is in {docbook-xsl}/xhtml/autoidx.xsl -->
  <xsl:template match="indexterm" mode="index-secondary">
    <xsl:param name="scope" select="."/>
    <xsl:variable name="key" select="concat(normalize-space(concat(primary/@sortas, &quot; &quot;, primary)), &quot; &quot;, normalize-space(concat(secondary/@sortas, &quot; &quot;, secondary)))"/>
    <xsl:variable name="refs" select="key('secondary', $key)[count(ancestor::node()|$scope) = count(ancestor::node())]"/>
    <li>
      <strong class="secitem">
        <xsl:value-of select="secondary"/>
        <xsl:text>: </xsl:text>
      </strong>
      <span class='indexref'>
        <xsl:for-each select="$refs[generate-id() = generate-id(key('secondary-section', concat($key, &sep;, &section.id;))[&scope;][1])]">
          <xsl:apply-templates select="." mode="reference">
            <xsl:with-param name="scope" select="$scope"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </span>
    </li>
  </xsl:template>

  <!-- Drop $term.separator and $number.separator from here as customized ones
       are added in the output flow.
       As all the indexterms in the book have @zone attributes, removed a lot of
       unused code.
       The original template is in {docbook-xsl}/xhtml/autoidx.xsl -->
  <xsl:template match="indexterm" mode="reference">
    <xsl:param name="scope" select="."/>
    <xsl:call-template name="reference">
      <xsl:with-param name="zones" select="normalize-space(@zone)"/>
      <xsl:with-param name="scope" select="$scope"/>
    </xsl:call-template>
  </xsl:template>

  <!-- The target links:
       Changed link separator
       On the second @zone link, we use a fixed string for the text with gentext
       support.
       Assume that there are no more than 2 @zone in a indexterm.
       Use href.target.uri named template to resolve the links. It is faster
       than the default href.target named template.
       The original template is in {docbook-xsl}/xhtml/autoidx.xsl -->
  <xsl:template name="reference">
    <xsl:param name="scope" select="."/>
    <xsl:param name="zones"/>
    <xsl:choose>
      <xsl:when test="contains($zones, ' ')">
        <xsl:variable name="zone" select="substring-before($zones, ' ')"/>
        <xsl:variable name="zone2" select="substring-after($zones, ' ')"/>
        <xsl:variable name="target" select="key('sections', $zone)[&scope;]"/>
        <xsl:variable name="target2" select="key('sections', $zone2)[&scope;]"/>
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target.uri">
              <xsl:with-param name="object" select="$target[1]"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="$target[1]" mode="index-title-content"/>
        </a>
        <xsl:text> -- </xsl:text>
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target.uri">
              <xsl:with-param name="object" select="$target2[1]"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:call-template name="gentext">
            <xsl:with-param name="key">description</xsl:with-param>
          </xsl:call-template>
        </a>
        <br/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="zone" select="$zones"/>
        <xsl:variable name="target" select="key('sections', $zone)[&scope;]"/>
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target.uri">
              <xsl:with-param name="object" select="$target[1]"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="$target[1]" mode="index-title-content"/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
