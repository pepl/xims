<?xml version="1.0"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    version="1.0"
    >
    <!--
    This stylesheet is a slightly modified version of AxKit's original error.xsl

    # Copyright (c) 2002-2011 The XIMS Project.
    # See the file "LICENSE" for information and conditions for use, reproduction,
    # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
    # $Id$
    -->
    <xsl:output method="html" encoding="ISO-8859-1"/>

    <xsl:template match="bt">

        <tr>
            <xsl:if test="position() mod 2">
                <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
            </xsl:if>
            <td>
                <xsl:value-of select="@level"/>
            </td>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="file|line">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="/">
        <html>
            <head>
                <title>AxKit Server Error</title>
                <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css" />
            </head>
            <body bgcolor="#ffffff" text="#000000" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
                <table width="75%" border="0" style="margin-top: 20px; margin-left: 10px; padding-left: 0px">
                    <tr>
                        <td>
                            <h1>AxKit Server Error</h1>
                            <p>The following error occurred: <xsl:value-of select="/error/msg"/></p>
                            <h2>Stack Trace:</h2>

                            <table>
                                <tr bgcolor="blue"><th>Level</th><th>File</th><th>Line #</th></tr>

                                <xsl:apply-templates select="/error/stack_trace/*"/>

                            </table>
                        </td>
                    </tr>
                </table>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
