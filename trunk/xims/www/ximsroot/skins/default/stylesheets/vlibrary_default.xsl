<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<!DOCTYPE stylesheet [
<!ENTITY  fromchars "'aÄäbcdefghijklmnoÖöpqrsßtuÜüvwxyz@„&quot;'">
<!ENTITY    tochars "'AAABCDEFGHIJKLMNOOOPQRSSTUUUVWXYZ___'">
]>


<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="exslt">

  <xsl:import href="vlibrary_common.xsl"/>

  <xsl:variable name="subjectcolumns" select="'3'"/>

  <xsl:key name="subject_id" match="subject/id" use="."/>

  <xsl:variable name="subjects">
    <xsl:for-each select="/document/context/vlsubjectinfo/subject">
      <xsl:copy>
        <xsl:copy-of select="*"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="vlib_ots">
    <xsl:for-each select="/document/object_types/object_type[parent_id !='']">
      <xsl:copy>
        <xsl:copy-of select="name|@id"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="head_default"/>
      <body>
        <xsl:call-template name="header">
          <xsl:with-param name="createwidget">true</xsl:with-param>
          <xsl:with-param name="parent_id">
            <xsl:value-of select="/document/object_types/object_type[name='VLibraryItem']/@id" />
          </xsl:with-param>
        </xsl:call-template>
        <div id="vlbody">
          <h1><xsl:value-of select="title"/></h1>
          <div>
            <xsl:apply-templates select="abstract"/>
          </div>
          <xsl:call-template name="search_switch">
            <xsl:with-param name="mo" select="'subject'"/>
          </xsl:call-template>
          <xsl:call-template name="chronicle_switch" />
          <xsl:apply-templates select="/document/context/vlsubjectinfo"/>
        </div>
        <table align="center" width="98.7%" class="footer">
          <xsl:call-template name="footer"/>
        </table>
        <xsl:call-template name="jquery-listitems-bg">
          <xsl:with-param name="pick" select="'td.vliteminfo'"/>
        </xsl:call-template>
        <xsl:call-template name="script_bottom"/>
        <script type="text/javascript">
          function refresh() {
             window.document.location.reload();
          }; 
        </script>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="vlsubjectinfo">
    <xsl:variable name="sorteddistinctsubjects">
      <xsl:for-each select="/document/context/vlsubjectinfo/subject[object_count &gt; 0 and generate-id(id)=generate-id(key('subject_id',id)[1])]">
        <xsl:sort select="translate(name,&fromchars;,&tochars;)"
                  order="ascending"/>
        <xsl:copy>
          <xsl:copy-of select="*"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="unmappeddistinctsubjects">
      <xsl:for-each select="/document/context/vlsubjectinfo/subject[object_count = 0 and generate-id(id)=generate-id(key('subject_id',id)[1])]">
        <xsl:sort select="translate(lastname,&fromchars;,&tochars;)"
                  order="ascending"/>
        <xsl:sort select="translate(firstname,&fromchars;,&tochars;)"
                  order="ascending"/>
        <xsl:copy>
          <xsl:copy-of select="*"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>

    <table width="600" border="0" align="center" id="vlpropertyinfo">
      <tr>
        <th colspan="{$subjectcolumns}">
          <xsl:value-of select="$i18n_vlib/l/subjects"/>
        </th>
      </tr>
      <xsl:apply-templates select="exslt:node-set($sorteddistinctsubjects)/subject[(position()-1) mod $subjectcolumns = 0]">
        <!-- do not ask me why the second sorting is neccessary here ... 8-{ -->
        <xsl:sort select="translate(name,&fromchars;,&tochars;)"
                  order="ascending"/>
      </xsl:apply-templates>

      <xsl:if test="count(/document/context/vlsubjectinfo/subject[object_count = 0])&gt;0">
        <tr>
          <th colspan="{$subjectcolumns}">
            <xsl:value-of select="concat($i18n_vlib/l/unmapped, ' ', $i18n_vlib/l/subjects)"/>
          </th>
        </tr>
        <xsl:apply-templates select="exslt:node-set($unmappeddistinctsubjects)/subject[(position()-1) mod $subjectcolumns = 0]">
          <!-- do not ask me why the second sorting is neccessary here ... 8-{ -->
          <xsl:sort select="translate(lastname,&fromchars;,&tochars;)"
                    order="ascending"/>
          <xsl:sort select="translate(firstname,&fromchars;,&tochars;)"
                    order="ascending"/>
        </xsl:apply-templates>
      </xsl:if>

    </table>
  </xsl:template>

  <xsl:template match="subject">
    <xsl:call-template name="subject_item">
      <xsl:with-param name="colms" select="$subjectcolumns"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="subject_item">
    <tr>
      <td class="vliteminfo">
        <xsl:call-template name="subject_item_div"/>

      </td>
      <xsl:for-each select="following-sibling::node()[position() &lt; $colms]">
        <td class="vliteminfo">
          <xsl:call-template name="subject_item_div"/>
        </td>
      </xsl:for-each>
    </tr>
  </xsl:template>

  <xsl:template name="subject_item_div">
    <xsl:variable name="lmts">
      <xsl:for-each select="exslt:node-set($subjects)/subject[id=current()/id]/last_modification_timestamp">
        <xsl:sort select="concat(year,month,day,hour,minute,second)" order="descending"/>
        <xsl:copy>
          <xsl:copy-of select="*"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>
    <div class="vliteminfo" name="vliteminfo" align="center">
      <div>
        <xsl:call-template name="property_link">
          <xsl:with-param name="mo" select="'subject'"/>
        </xsl:call-template>
      </div>
      <div>
        <xsl:apply-templates select="exslt:node-set($subjects)/subject[id=current()/id]" mode="item_count">
          <xsl:sort select="object_count" order="descending"/>
        </xsl:apply-templates>
      </div>
      <xsl:if test="exslt:node-set($lmts)/last_modification_timestamp/day">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$i18n_vlib/l/last_modified_at"/>
        <br />
        <xsl:apply-templates select="exslt:node-set($lmts)/last_modification_timestamp[1]"
          mode="datetime" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="subject" mode="item_count">
    <xsl:value-of select="object_count"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="exslt:node-set($vlib_ots)/object_type[@id=current()/object_type_id]/name"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="decide_plural">
      <xsl:with-param name="objectitems_count"
        select="object_count"/>
    </xsl:call-template>
    <br/>
  </xsl:template>

  <xsl:template name="cttobject.options.copy"/>

</xsl:stylesheet>
