<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:import href="common.xsl"/>
    <xsl:import href="../link_common.xsl"/>
    <xsl:output method="xml" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <p class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitletarget-edit"/>
                    <tr>
                        <td colspan="3">
                            Titel: <xsl:value-of select="title"/>
                        </td>
                    </tr>
                    <xsl:call-template name="contentcolumns"/>
                    <xsl:call-template name="contentfilter"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </p>
        <br />
        <xsl:call-template name="canceledit"/>
    </body>
</html>
</xsl:template>

    <xsl:template name="contentcolumns">
        <!--
        don't list common stuff like language, major/ minor ids, OTs ...
        such information is loaded everytime and is not selectable
        -->
        <tr>
            <td colspan="2">
                Neben den Standardspalten können Sie hier
                <b>zusätzliche</b> Informationen einbringen, die das Portlet
                enthalten soll. (Hinweis: Diese Informationen
                sind nur einbringbar, wenn das Objekt eine solche
                Information besitzt!)
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <table border="0" cellspacing="0" cellpadding="1" width="100%">
                    <tr>
                        <td width="20%">
                            erstellt von
                        </td>
                        <td valign="top" width="20%">
                            <input type="checkbox" name="col_created_by_fullname"><xsl:if test="body/content/column[@name = 'created_by_firstname']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                        </td>
                        <td width="20%">
                            Erstellungszeit
                        </td>
                        <td valign="top" width="40%">
                            <input type="checkbox" name="col_creation_timestamp"><xsl:if test="body/content/column[@name = 'creation_timestamp']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            zuletzt geändert von
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_last_modified_by_fullname"><xsl:if test="body/content/column[@name = 'last_modified_by_firstname']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                        </td>
                        <td>
                            zuletzt geändert um
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
                            zuletzt veröffentlicht um
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_last_publication_timestamp"><xsl:if test="body/content/column[@name = 'last_publication_timestamp']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                        </td>
                    </tr>

                    <tr>
                        <td>Inhaber</td>
                        <td><input type="checkbox" name="col_owned_by_firstname"><xsl:if test="body/content/column[@name = 'owned_by_firstname']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input></td>
                        <td>
                            Neue Fahne
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_marked_new"><xsl:if test="body/content/column[@name = 'marked_new']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            Status des Dokuments
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_minor_status"><xsl:if test="body/content/column[@name = 'minor_status']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                        </td>
                        <td>
                            zusätzliche Attribute
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_attributes"><xsl:if test="body/content/column[@name = 'attributes']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            Abstract
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_abstract"><xsl:if test="body/content/column[@name = 'abstract']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                        </td>
                        <td>
                            Bild URI
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_imageid"><xsl:if test="body/content/column[@name = 'image_id']"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
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
            </td>
        </tr>
        <tr>
            <td>
                Wie tief soll der Baum aufgegliedert werden?
            </td>
            <td>
                <select name="levels">
                    <option value="1"><xsl:if test="body/content/depth[@level =1]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>1</option>
                    <option value="2"><xsl:if test="body/content/depth[@level =2]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>2</option>
                    <option value="3"><xsl:if test="body/content/depth[@level =3]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>3</option>
                    <option value="4"><xsl:if test="body/content/depth[@level =4]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>4</option>
                    <option value="5"><xsl:if test="body/content/depth[@level =5]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>5</option>
                    <option value="6"><xsl:if test="body/content/depth[@level =6]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>6</option>
                    <option value="7"><xsl:if test="body/content/depth[@level =7]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>7</option>
                    <option value="8"><xsl:if test="body/content/depth[@level =8]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>8</option>
                    <option value="9"><xsl:if test="body/content/depth[@level =9]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>9</option>
                    <option value="10"><xsl:if test="body/content/depth[@level =10]"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>10</option>
                </select><xsl:text> Level</xsl:text>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="contentfilter">
        <!-- filters are different than the columns themself. the
        tagged item here may not appear in the columns -->
        <tr>
            <td colspan="2">
                Filters
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <table border="0" cellspacing="0" cellpadding="1" width="100%">
                    <tr>
                        <td width="20%">
                            Nur Objekte die als neu markiert sind:<br/>
                            Nur Objekte die publiziert markiert sind:

                        </td>
                        <td valign="top" width="20%">
                            <input type="checkbox" name="filternews"><xsl:if test="body/filter[new=1]"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                            <input type="checkbox" name="filterpublished"><xsl:if test="body/filter[published=1]"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
                        </td>
                        <td valign="top" width="20%"><xsl:text>Filter Objekt Typen </xsl:text></td>
                        <td valign="top" width="20%"><xsl:text> </xsl:text></td>
                    </tr>
                    <tr>
                        <td colspan="2">Extra Filter:</td>
                        <td rowspan="2">
                            <xsl:apply-templates select="/document/object_types/object_type[name!='Portlet' and name!='Portal' and name!='Annotation' and name!='AnonDiscussionForumContrib' and name!='AnonDiscussionForum']"/>
                        </td>
                        <td><xsl:text> </xsl:text></td>
                    </tr>
                    <tr>
                        <td colspan="2" valign="top">
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
                        <td><xsl:text> </xsl:text></td>
                    </tr>
                </table>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="object_types/object_type">
        <input type="checkbox" name="ot_{name}"><xsl:if test="/document/context/object/body/content/object-type/@name = name"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if><xsl:value-of select="name"/></input>
        <br/>
    </xsl:template>

    <xsl:template match="*" mode="filter">
         <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="filter"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
