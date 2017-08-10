<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_remove.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
    <xsl:import href="../users_remove.xsl"/>

    <xsl:template name="confirm_user_deletion">
        <tr>
          <td>
            <div>
            Sie sind dabei, den Account '<xsl:value-of select="$name"/>' zu löschen.
            </div>
            <div style="margin: 5px;">
                <strong>Das ist eine endgültige Aktion, die nicht rückgängig gemacht werden kann.</strong>
            </div>
            <div>
            Klicken Sie auf 'Bestätigen' um fortzufahren, oder auf 'Abbrechen'.
            </div>
          </td>
        </tr>

        <xsl:call-template name="exitform">
            <xsl:with-param name="action" select="'remove_update'"/>
            <xsl:with-param name="save" select="'Bestätigen'"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>

