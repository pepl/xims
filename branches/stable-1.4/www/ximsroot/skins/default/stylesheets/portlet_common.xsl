<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:exslt="http://exslt.org/common"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="link_common.xsl"/>

<xsl:variable name="i18n_portlet" select="document(concat($currentuilanguage,'/i18n_portlet.xml'))"/>

<!-- think of an object-type property "independent" instead of filtering object_types by name -->
<xsl:variable name="filtered_ots">
    <xsl:for-each select="/document/object_types/object_type[name != 'Portlet' and name != 'Portal' and name != 'AnonDiscussionForumContrib' and name != 'Annotation' and name != 'VlibraryItem' and name != 'DocBookXML']">
        <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
        <xsl:copy>
            <xsl:copy-of select="@*|*"/>
        </xsl:copy>
    </xsl:for-each>
</xsl:variable>

<xsl:template name="extra_properties">
    <table>
        <tr>
            <td colspan="4">
                <xsl:value-of select="$i18n_portlet/l/Extra_Properties"/>
            </td>
        </tr>
        <tr>
            <td width="20%">
                <xsl:value-of select="$i18n_portlet/l/Creator"/>
            </td>
            <td valign="top" width="20%">
                <input type="checkbox" name="col_created_by_fullname"><xsl:if test="body/content/column[@name = 'created_by_firstname']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
            <td width="20%">
                <xsl:value-of select="$i18n_portlet/l/Creation_timestamp"/>
            </td>
            <td valign="top" width="40%">
                <input type="checkbox" name="col_creation_timestamp"><xsl:if test="body/content/column[@name = 'creation_timestamp']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
        </tr>
        <tr>
            <td>
                <xsl:value-of select="$i18n_portlet/l/Last_modifier"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_last_modified_by_fullname"><xsl:if test="body/content/column[@name = 'last_modified_by_firstname']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
            <td>
                <xsl:value-of select="$i18n_portlet/l/Last_modification_timestamp"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_last_modification_timestamp"><xsl:if test="body/content/column[@name = 'last_modification_timestamp']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
        </tr>
        <tr>
            <td>
                <xsl:text> </xsl:text>
            </td>
            <td valign="top">
                <xsl:text> </xsl:text>
            </td>
            <td>
                <xsl:value-of select="$i18n_portlet/l/Publication_timestamp"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_last_publication_timestamp"><xsl:if test="body/content/column[@name = 'last_publication_timestamp']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
        </tr>
        <tr>
            <td>
                <xsl:value-of select="$i18n_portlet/l/Valid_from_timestamp"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_valid_from_timestamp"><xsl:if test="body/content/column[@name = 'valid_from_timestamp']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
            <td>
                <xsl:value-of select="$i18n_portlet/l/Valid_to_timestamp"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_valid_to_timestamp"><xsl:if test="body/content/column[@name = 'valid_to_timestamp']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
        </tr>
        <tr>
            <td>
                <xsl:value-of select="$i18n_portlet/l/Owner"/>
            </td>
            <td><input type="checkbox" name="col_owned_by_fullname"><xsl:if test="body/content/column[@name = 'owned_by_firstname']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input></td>
            <td>
                <xsl:value-of select="$i18n_portlet/l/Marked_new"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_marked_new"><xsl:if test="body/content/column[@name = 'marked_new']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
        </tr>
        <tr>
            <td>
                <xsl:value-of select="$i18n/l/Status"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_status"><xsl:if test="body/content/column[@name = 'status']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
            <td>
                <xsl:value-of select="$i18n_portlet/l/Attributes"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_attributes"><xsl:if test="body/content/column[@name = 'attributes']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
        </tr>
        <tr>
            <td>
                <xsl:value-of select="$i18n/l/Abstract"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_abstract"><xsl:if test="body/content/column[@name = 'abstract']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
            <td>
                <xsl:value-of select="$i18n/l/Image"/>
            </td>
            <td valign="top">
                <input type="checkbox" name="col_image_id"><xsl:if test="body/content/column[@name = 'image_id']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
        </tr>
        <tr>
            <td>
                Body
            </td>
            <td valign="top">
                <input type="checkbox" name="col_body"><xsl:if test="body/content/column[@name = 'body']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
            <td colspan="2"><xsl:text> </xsl:text></td>
        </tr>
    </table>
</xsl:template>

<xsl:template name="contentoptions">
    <xsl:call-template name="tree_depth"/>
    <xsl:call-template name="add_documentlinks"/>
</xsl:template>

<xsl:template name="tree_depth">
    <table>
        <tr>
            <td width="250">
                <xsl:value-of select="$i18n_portlet/l/How_deep"/>
            </td>
            <td>
                <select name="depth">
                    <option value="2"><xsl:if test="body/content[depth =2]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>2</option>
                    <option value="3"><xsl:if test="body/content[depth =3]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>3</option>
                    <option value="4"><xsl:if test="body/content[depth =4]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>4</option>
                    <option value="5"><xsl:if test="body/content[depth =5]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>5</option>
                </select><xsl:text> Levels</xsl:text>
            </td>
            <td>
                <input name="f_depth" type="radio" value="true">
                  <xsl:if test="body/content/depth != ''">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                  </xsl:if>
                </input><xsl:value-of select="$i18n/l/Yes"/>
                <input name="f_depth" type="radio" value="false">
                  <xsl:if test="not(body/content/depth) or body/content/depth = ''">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                  </xsl:if>
                </input><xsl:value-of select="$i18n/l/No"/>
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template name="add_documentlinks">
    <table>
        <tr>
            <td>
                <xsl:value-of select="$i18n_portlet/l/Add_documentlinks"/>
            </td>
            <td>
                <input type="checkbox" name="documentlinks"><xsl:if test="body/content[documentlinks=1]"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template name="filter_latest">
    <tr>
        <td width="250">
            <xsl:value-of select="$i18n_portlet/l/Filter_latest"/>:
            <select name="latest">
                <option value="1"><xsl:if test="body/content[latest =1]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>1</option>
                <option value="2"><xsl:if test="body/content[latest =2]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>2</option>
                <option value="3"><xsl:if test="body/content[latest =3]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>3</option>
                <option value="4"><xsl:if test="body/content[latest =4]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>4</option>
                <option value="5"><xsl:if test="body/content[latest =5]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>5</option>
                <option value="6"><xsl:if test="body/content[latest =6]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>6</option>
                <option value="7"><xsl:if test="body/content[latest =7]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>7</option>
                <option value="8"><xsl:if test="body/content[latest =8]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>8</option>
                <option value="9"><xsl:if test="body/content[latest =9]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>9</option>
                <option value="10"><xsl:if test="body/content[latest =10]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>10</option>
                <option value="15"><xsl:if test="body/content[latest =15]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>15</option>
                <option value="20"><xsl:if test="body/content[latest =20]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>20</option>
                <option value="25"><xsl:if test="body/content[latest =25]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>25</option>
                <option value="30"><xsl:if test="body/content[latest =30]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>30</option>
            </select>
        </td>
        <td>
            <input name="f_latest" type="radio" value="true">
              <xsl:if test="body/content/latest != ''">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/Yes"/>
            <input name="f_latest" type="radio" value="false">
              <xsl:if test="not(body/content/latest) or body/content/latest = ''">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/No"/>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <xsl:value-of select="$i18n_portlet/l/Filter_latest_sortkey"/>:
            <select name="f_latest_sortkey">
                <option value="last_modification_timestamp">
                    <xsl:value-of select="$i18n_portlet/l/Last_modification_timestamp"/>
                </option>
                <option value="valid_from_timestamp">
                    <xsl:if test="body/content/latest_sortkey != '' and body/content/latest_sortkey = 'valid_from_timestamp'">
                        <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$i18n_portlet/l/Valid_from_timestamp"/>
                </option>
            </select>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('filter_latest_sortkey')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="contentfilters">
    <table cellspacing="5">
    <xsl:call-template name="filter_latest"/>
    <tr>
        <td>
            <xsl:value-of select="$i18n_portlet/l/Filter_marked_new"/>:
        </td>
        <td>
            <input type="checkbox" name="filternews"><xsl:if test="body/filter[marked_new=1]"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input><br/>
        </td>
    </tr>
    <tr>
        <td>
            <xsl:value-of select="$i18n_portlet/l/Filter_published"/>:
        </td>
        <td>
            <input type="checkbox" name="filterpublished"><xsl:if test="body/filter[published=1]"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
        </td>
    </tr>
    <tr>
      <td>
        <xsl:value-of select="$i18n_portlet/l/Filter_title"/>:
      </td>
      <td>
        <input name="filtertitle" 
               class="text"
               type="text"
               size="30"
               maxlength="50"
               value="{body/filter/title/text()}"/>
      </td>
    </tr>
    <tr>
      <td>
        <xsl:value-of select="$i18n_portlet/l/Filter_location"/>:
      </td>
      <td>
        <input name="filterlocation" 
               class="text"
               type="text"
               size="30"
               maxlength="50"
               value="{body/filter/location/text()}"/>
      </td>
    </tr>
    <tr>
        <!--<td>Extra filters:</td>-->
        <td colspan="2">
            <xsl:value-of select="$i18n_portlet/l/Filter_object_types"/>:
        </td>
    </tr>
    <tr>
        <!-- reactivate after Portlet stuff is refactored and cleaned-up
        <td>
            <textarea name="extra_filters" rows="30" cols="45">
                <xsl:choose>
                    <xsl:when test="body/filter/*[not(name() = 'new') and not(name() = 'published')]">
                        <xsl:apply-templates select="body/filter/*[not(name() = 'new') and not(name() = 'published')]" mode="filter"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </textarea>
        </td>
        -->
        <td colspan="2" valign="top">
            <table>
                <tr>
                    <td valign="top">
                        <xsl:apply-templates select="exslt:node-set($filtered_ots)/object_type[position() mod 2 != 0 and name=fullname]"/>
                    </td>
                    <td valign="top">
                        <xsl:apply-templates select="exslt:node-set($filtered_ots)/object_type[position() mod 2 = 0 and name=fullname]"/>
                    </td>
                </tr>
            </table>
            <!-- Nodes outside the node-set cannot be checked, therefore we have to check the filtered object-types via JavaScript -->
            <xsl:apply-templates select="body/content/object-type"/>
            <xsl:call-template name="mk-inline-js">
              <xsl:with-param name="code">
              <![CDATA[
                var inputs = document.getElementsByTagName("input");
                var re = new RegExp("filter_ot_");
                var el;
                for (var i = inputs.length - 1; i > 0; --i ) {
                    re.test(inputs[i].name);
                    if (RegExp.rightContext.length > 0) {
                        el = document.getElementById("ot_" + RegExp.rightContext)
                        if ( el )
                            el.checked = 1;
                    }
                } 
              ]]>
	      </xsl:with-param>
            </xsl:call-template> 
        </td>
    </tr>
    </table>
</xsl:template>

<xsl:template match="object_type">
    <table width="100%">
        <tr>
            <td width="40">
                <xsl:value-of select="name"/>
            </td>
            <td align="right">
                <input type="checkbox" name="ot_{name}" id="ot_{name}"/>
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template match="object-type">
    <input type="hidden" name="filter_ot_{@name}"/>
</xsl:template>

<xsl:template match="*" mode="filter">
     <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="filter"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>

