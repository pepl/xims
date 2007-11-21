<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head-edit"/>
            <body>
                <div class="edit">
                    <xsl:call-template name="table-edit"/>
                    <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST">
                        <table border="0" width="98%">
                            <xsl:call-template name="tr-locationtitle-edit_doc"/>
                            <xsl:call-template name="tr-body-edit">
                                <xsl:with-param name="with_origbody" select="'yes'"/>
                            </xsl:call-template>
                            <tr>
                                <td colspan="3">
                                    <xsl:call-template name="testbodysxml"/>
                                    <xsl:call-template name="prettyprint"/>
                                </td>
                            </tr>
                            <xsl:call-template name="trytobalance"/>
                            <xsl:call-template name="tr-keywords-edit"/>
                            <xsl:call-template name="tr-abstract-edit"/>
                            <xsl:call-template name="markednew"/>
                            <xsl:call-template name="expandrefs"/>
                        </table>
                        <xsl:call-template name="saveedit"/>
                    </form>
                    <script type="text/javascript">
                        <!-- set checked attribute for trytobalance-input-element according to cookie -->
                        selTryToBalance(document.eform.trytobalance , readCookie('xims_trytobalancewell'));
                    </script>
                </div>
                <br />
                <xsl:call-template name="canceledit"/>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
