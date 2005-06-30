<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--$Id$-->
<xsl:template name="header">
    <tr>
        <td bgcolor="#123853" colspan="2"><span style="color:#ffffff; font-size:14pt;">The eXtensible Information Management System</span></td>
        <td bgcolor="#123853" align="right"><xsl:text>&#160;</xsl:text></td>
    </tr>
    <tr>
        <td class="pathinfo" colspan="2">
            <xsl:call-template name="pathinfo"/>
        </td>
        <td class="pathinfo" align="right">
            <a href="{$request.uri}?style=textonly">[textonly]</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
