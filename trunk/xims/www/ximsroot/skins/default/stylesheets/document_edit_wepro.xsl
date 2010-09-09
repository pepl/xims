<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>
    <xsl:import href="document_common.xsl"/>

    <xsl:variable name="bodycontent">
        <xsl:call-template name="body"/>
    </xsl:variable>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head-edit_wepro"/>
            <body>
                <div class="edit">
                    <xsl:call-template name="table-edit"/>
					<p style="color:maroon"><b>Lieber XIMS-Nutzer,<br/>bitte beachten Sie, dass der eWebEditPro 
					mit Ende Oktober nicht mehr zur Verfügung steht. Ab diesem Zeitpunkt wird Xims nur noch den 
					Editor TinyMCE unterstützen, für den wir aktuell neue Features und Formatierungsmöglichkeiten 
					entwickeln.<br/>Das Xims-Support Team</b></p>
                    <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                        <table border="0" width="98%">
                            <xsl:call-template name="tr-locationtitle-edit_doc"/>
                            <xsl:call-template name="tr-body-edit_wepro"/>
                            <xsl:call-template name="tr-keywords-edit"/>
                            <xsl:call-template name="tr-abstract-edit"/>
                            <xsl:call-template name="markednew"/>
                            <xsl:call-template name="expandrefs"/>
                        </table>
                        <xsl:call-template name="saveedit"/>
                    </form>
                </div>
                <br />
                <xsl:call-template name="canceledit"/>
                <xsl:call-template name="script_bottom"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="head-edit_wepro">
        <head>
            <title><xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
            <xsl:call-template name="css"/>
            <script src="{$ximsroot}wepro/ewebeditpro.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script type="text/javascript">
	    	<!-- tell ewebeditpro which HTML file to use for image selection -->
                function setEWProperties(sEditorName) {
                eWebEditPro.instances[sEditorName].editor.MediaFile().setProperty(&apos;TransferMethod&apos;,&apos;<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'/')"/>?contentbrowse=1;style=ewebeditimage;otfilter=Image&apos;);
                }
            </script>
        </head>
    </xsl:template>

    <xsl:template name="tr-body-edit_wepro">
        <tr>
            <td colspan="3">
                Body
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
                <br/>
                <input tabindex="30" type="hidden" name="body" id="body" value="{$bodycontent}" width="100%"/>
                <script language="JavaScript1.2">
                    <!-- for ewebedit: pull parent_id into a JavaScript variable -->
                    var parentID=&apos;<xsl:apply-templates select="@parent_id"/>&apos;;
                    var documentID=&apos;<xsl:apply-templates select="@id"/>&apos;;
                    var sEditorName = &apos;body&apos;;
		    <!-- set baseURL for editing on ID-bases -->
		    eWebEditPro.parameters.baseURL = &quot;<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'/')"/>&quot;;
		    eWebEditPro.onready = &apos;setEWProperties(sEditorName)&apos;;
                    eWebEditPro.create(sEditorName, &apos;99.5%&apos;, &apos;450&apos;);
                </script>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
