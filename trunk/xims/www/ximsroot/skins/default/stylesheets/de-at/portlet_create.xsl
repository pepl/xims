<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">
<xsl:import href="link_common.xsl"/>
<xsl:import href="../portlet_create.xsl"/>
<xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template name="contentcolumns">
        <!--
        don't list common stuff like language, major/ minor ids, OTs ...
        such information is loaded everytime and is not selectable
        -->
        <tr>
            <td colspan="3">
                Neben den Standardspalten können Sie hier
                <b>zusätzliche</b> Informationen einbringen, die das Portlet
                enthalten soll. (Hinweis: Diese Informationen
                sind nur einbringbar, wenn das Objekt eine solche
                Information besitzt!)
            </td>
        </tr>
        <tr>
            <td colspan="3">
                <table border="0" cellspacing="0" cellpadding="1" width="100%">
                    <tr>
                        <td width="20%">
                            erstellt von
                        </td>
                        <td valign="top" width="20%">
                            <input type="checkbox" name="col_created_by_fullname" checked="checked" />
                        </td>
                        <td width="20%">
                            Erstellungszeit
                        </td>
                        <td valign="top" width="40%">
                            <input type="checkbox" name="col_creation_timestamp" checked="checked" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            zuletzt geändert von
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_last_modified_by_fullname" checked="checked" />
                        </td>
                        <td>
                            zuletzt geändert um
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_last_modification_timestamp" checked="checked" />
                        </td>
                    </tr>

                    <tr>
                        <td>Inhaber</td>
                        <td><input type="checkbox" name="col_owned_by_fullname" checked="checked"/></td>
                        <td>
                            Neue Fahne
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_marked_new" checked="checked" />
                        </td>
                    </tr>

                    <tr>
                        <td>
                            Status des Dokuments
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_minor_status" checked="checked" />
                        </td>
                        <td>
                            zusätzliche Attribute
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_attributes"/>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            Abstract
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_abstract" checked="checked" />
                        </td>
                        <td>
                            Bild URI
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_image_id"/>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            Body
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_body" />
                        </td>
                        <td colspan="2"><xsl:text> </xsl:text></td>
                    </tr>
                </table>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>

