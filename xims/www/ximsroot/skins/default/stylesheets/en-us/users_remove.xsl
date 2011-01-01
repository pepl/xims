<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
    <xsl:import href="../users_remove.xsl"/>

    <xsl:template name="confirm_user_deletion">
        <tr>
          <td>
            <div>
                You are about to delete the user '<xsl:value-of select="$name"/>' from the system.
            </div>
            <div style="margin: 5px;">
                <strong>This is a permanent action that cannot be undone.</strong>
            </div>
            <div>
                Click 'Confirm' to continue, or 'Cancel' to return to the previous screen.
            </div>
          </td>
        </tr>

        <xsl:call-template name="exitform">
            <xsl:with-param name="action" select="'remove_update'"/>
            <xsl:with-param name="save" select="'Confirm'"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>

