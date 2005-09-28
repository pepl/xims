<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns="http://www.w3.org/1999/xhtml">
<!--$Id$-->

<xsl:import href="include/common.xsl"/>
<xsl:param name="request.headers.host"/>
<xsl:param name="links"/>

<xsl:output method="html" encoding="utf-8"/>

<xsl:template match="/page">
    <html>
    <head>
      <xsl:call-template name="meta"/>
      <title><xsl:value-of select="rdf:RDF/rdf:Description/dc:title/text()"/></title>
      <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css" />
      <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css" />
    </head>

    <body>
	<p class="printzitat">
        Document:<br />
      	<xsl:value-of select="rdf:RDF/rdf:Description/dc:creator"/>,
      	<xsl:value-of select="rdf:RDF/rdf:Description/dc:title"/>,
    	[<xsl:value-of select="concat('http://',$request.headers.host,$request.uri)"/>],
    	<!-- http:// ist fest mitcodiert, da kein dafür kein geeigneter funktionierender Parameter gefunden wurde -->
     	<xsl:value-of select="rdf:RDF/rdf:Description/dc:date/dcq:modified/rdf:Description/rdf:value"/>
      	<!-- hier sollte das aktulle Tagesdatum stehen; ist zum gegenwärtigen Zeitpunkt noch nicht verfügbar -->
     	<br /><br />
	<xsl:choose>
            	<xsl:when test="$links='1'">
                	<a href="{$request.uri}?style=print">fade out linklist</a> |
             	</xsl:when>
             	<xsl:otherwise>
                    <a href="{$request.uri}?style=print;links=1">show linklist</a> |
            	</xsl:otherwise>
   	</xsl:choose>
      	<a href="javascript:print()">print document</a> |
      	<a href="{$request.uri}">back to htmlversion</a>
    	</p>
       <hr />

      	<!-- Begin content -->
	<table>
	   	<tr>
	            <td class="printzitatContent">
	                <xsl:apply-templates select="body"/>
	            </td>
	        </tr>
	</table>

	<xsl:if test="$links='1'">
        <hr />
         <table class="printzitat">
            <tr>
                <th style="background-color:#ffffff; text-align:left;">Documentlinks</th>
            </tr>

             <xsl:choose>
                    <xsl:when test="//a">
                        <xsl:for-each select="//a" >
                        <tr>
                            <td>[<xsl:number level="any"/>] <xsl:value-of select="@href" /></td>
                        </tr>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                            <tr>
                                <td>there are no links in this document</td>
                            </tr>
                    </xsl:otherwise>
               </xsl:choose>

              </table>
    	</xsl:if>
      	<!-- End content -->

      </body>
    </html>
</xsl:template>


<xsl:template match="a">
    <xsl:choose>
    <xsl:when test="$links='1'">
         <a href="{@href}"><xsl:value-of select="text()"/></a> [<xsl:number level="any"/>]
    </xsl:when>
    <xsl:otherwise>
         <xsl:copy>
               <xsl:copy-of select="@*"/>
               <xsl:apply-templates/>
        </xsl:copy>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>
