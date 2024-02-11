<?xml version='1.0' encoding='UTF-8'?>

<!DOCTYPE xsl:stylesheet [
<!ENTITY lowercase "'AaÀàÁáÂâÃãÄäÅåĀāĂăĄąǍǎǞǟǠǡǺǻȀȁȂȃȦȧḀḁẚẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặBbƀƁɓƂƃḂḃḄḅḆḇCcÇçĆćĈĉĊċČčƇƈɕḈḉDdĎďĐđƊɗƋƌǅǲȡɖḊḋḌḍḎḏḐḑḒḓEeÈèÉéÊêËëĒēĔĕĖėĘęĚěȄȅȆȇȨȩḔḕḖḗḘḙḚḛḜḝẸẹẺẻẼẽẾếỀềỂểỄễỆệFfƑƒḞḟGgĜĝĞğĠġĢģƓɠǤǥǦǧǴǵḠḡHhĤĥĦħȞȟɦḢḣḤḥḦḧḨḩḪḫẖIiÌìÍíÎîÏïĨĩĪīĬĭĮįİƗɨǏǐȈȉȊȋḬḭḮḯỈỉỊịJjĴĵǰʝKkĶķƘƙǨǩḰḱḲḳḴḵLlĹĺĻļĽľĿŀŁłƚǈȴɫɬɭḶḷḸḹḺḻḼḽMmɱḾḿṀṁṂṃNnÑñŃńŅņŇňƝɲƞȠǋǸǹȵɳṄṅṆṇṈṉṊṋOoÒòÓóÔôÕõÖöØøŌōŎŏŐőƟƠơǑǒǪǫǬǭǾǿȌȍȎȏȪȫȬȭȮȯȰȱṌṍṎṏṐṑṒṓỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợPpƤƥṔṕṖṗQqʠRrŔŕŖŗŘřȐȑȒȓɼɽɾṘṙṚṛṜṝṞṟSsŚśŜŝŞşŠšȘșʂṠṡṢṣṤṥṦṧṨṩTtŢţŤťŦŧƫƬƭƮʈȚțȶṪṫṬṭṮṯṰṱẗUuÙùÚúÛûÜüŨũŪūŬŭŮůŰűŲųƯưǓǔǕǖǗǘǙǚǛǜȔȕȖȗṲṳṴṵṶṷṸṹṺṻỤụỦủỨứỪừỬửỮữỰựVvƲʋṼṽṾṿWwŴŵẀẁẂẃẄẅẆẇẈẉẘXxẊẋẌẍYyÝýÿŸŶŷƳƴȲȳẎẏẙỲỳỴỵỶỷỸỹZzŹźŻżŽžƵƶȤȥʐʑẐẑẒẓẔẕẕ'">
<!ENTITY uppercase "'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDDDDDDEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEFFFFFFGGGGGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIJJJJJJKKKKKKKKKKKKKKLLLLLLLLLLLLLLLLLLLLLLLLLLMMMMMMMMMNNNNNNNNNNNNNNNNNNNNNNNNNNNOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOPPPPPPPPQQQRRRRRRRRRRRRRRRRRRRRRRRSSSSSSSSSSSSSSSSSSSSSSSTTTTTTTTTTTTTTTTTTTTTTTTTUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUVVVVVVVVWWWWWWWWWWWWWWWXXXXXXYYYYYYYYYYYYYYYYYYYYYYYZZZZZZZZZZZZZZZZZZZZZ'">
<!ENTITY primary   'normalize-space(concat(primary/@sortas, primary[not(@sortas) or @sortas = ""]))'>
<!ENTITY scope     "count(ancestor::node()|$scope) = count(ancestor::node()) and ($role = @role or $type = @type or (string-length($role) = 0 and string-length($type) = 0))">
]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

  <!-- This stylesheet controls how the Index is generated.
       Entities comes from {docbook-xsl}/common/entities.ent -->

    <!-- Override for punctuation separating an index term from its list
         of page references. -->
  <xsl:param name="index.term.separator" select="': '"></xsl:param>

    <!-- Divisions title properties. -->
  <xsl:attribute-set name="index.div.title.properties">
    <xsl:attribute name="margin-left">0pt</xsl:attribute>
    <xsl:attribute name="font-size">14.4pt</xsl:attribute>
    <xsl:attribute name="font-family">
      <xsl:value-of select="$title.fontset"/>
    </xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="space-before.optimum">1em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0.8em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">1.2em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0.3em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0.7em</xsl:attribute>
    <xsl:attribute name="start-indent">0pt</xsl:attribute>
  </xsl:attribute-set>

    <!-- Properties applied to the block containing entries in an Index. -->
  <xsl:attribute-set name="index.entry.properties">
    <xsl:attribute name="start-indent">0.5pc</xsl:attribute>
  </xsl:attribute-set>

    <!-- Divisions:
          Translate alphabetical divisions titles to by-type titles. -->
    <!-- The original template is in {docbook-xsl}/fo/autoidx.xsl -->
  <xsl:template match="indexterm" mode="index-div-basic">
    <xsl:param name="scope" select="."/>
    <xsl:param name="role" select="''"/>
    <xsl:param name="type" select="''"/>
    <xsl:variable name="key"
                  select="translate(substring(&primary;, 1, 1),&lowercase;,&uppercase;)"/>
    <xsl:variable name="divtitle" select="translate($key, &lowercase;, &uppercase;)"/>
    <xsl:if test="key('letter', $key)[&scope;]
                  [count(.|key('primary', &primary;)[&scope;][1]) = 1]">
      <fo:block>
        <xsl:if test="contains(concat(&lowercase;, &uppercase;), $key)">
          <xsl:call-template name="indexdiv.title">
            <xsl:with-param name="titlecontent">
              <xsl:choose>
                <xsl:when test="$divtitle = 'A'">
                  <xsl:call-template name="gentext">
                    <xsl:with-param name="key">Packages</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="$divtitle = 'B'">
                  <xsl:call-template name="gentext">
                    <xsl:with-param name="key">Programs</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="$divtitle = 'C'">
                  <xsl:call-template name="gentext">
                    <xsl:with-param name="key">Libraries</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="$divtitle = 'D'">
                  <xsl:choose>
                    <xsl:when test="$book-type = 'blfs'">
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key">Kernel Configuration</xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key">Scripts</xsl:with-param>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="$divtitle = 'E'">
                  <xsl:choose>
                    <xsl:when test="$book-type = 'blfs'">
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key">Configuration Files</xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key">Others</xsl:with-param>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="$divtitle = 'F'">
                    <xsl:call-template name="gentext">
                      <xsl:with-param name="key">Bootscripts</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$divtitle = 'G'">
                    <xsl:call-template name="gentext">
                      <xsl:with-param name="key">Others</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$divtitle"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <fo:block xsl:use-attribute-sets="index.entry.properties">
          <xsl:apply-templates select="key('letter', $key)[&scope;]
                                      [count(.|key('primary', &primary;)[&scope;][1])=1]"
                              mode="index-primary">
            <xsl:sort select="translate(&primary;, &lowercase;, &uppercase;)"/>
            <xsl:with-param name="scope" select="$scope"/>
            <xsl:with-param name="role" select="$role"/>
            <xsl:with-param name="type" select="$type"/>
          </xsl:apply-templates>
        </fo:block>
      </fo:block>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
