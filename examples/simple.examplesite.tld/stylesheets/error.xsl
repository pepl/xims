<?xml version="1.0"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/TR/xhtml1/strict"
    version="1.0"
    >
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
                <title>Server Error</title>
                <link rel="stylesheet" href="/stylesheets/default.css" type="text/css" />
            </head>
            <body>
                <h1>Server Error</h1>
                <p>The following error occurred: <xsl:value-of select="/error/msg"/></p>
                <h2>Stack Trace:</h2>
                <table>
                    <tr bgcolor="blue"><th>Level</th><th>File</th><th>Line #</th></tr>

                    <xsl:apply-templates select="/error/stack_trace/*"/>

                </table>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
