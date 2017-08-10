<?xml version="1.0" encoding="utf-8" ?>    
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_pub_preview.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns="http://www.w3.org/1999/xhtml">
   
<xsl:import href="public/common.xsl"/>
<xsl:param name="request.uri"/>

<xsl:output method="html" encoding="utf-8"/>

<xsl:template match="/document/context/object">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
    <head>
          <xsl:call-template name="meta"/>
          <title><xsl:value-of select="title"/></title>
          <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
          <script src="/scripts/default.js" type="text/javascript"><xsl:comment/>
          </script>
    </head>

    <body margintop="0" marginleft="0" marginwidth="0" marginheight="0">
          <table border="0" cellpadding="0" cellspacing="0" width="790">
               <xsl:call-template name="header">
                    <xsl:with-param name="no_navigation_at_all">true</xsl:with-param>
               </xsl:call-template>
               <tr>
                    <td class="links" colspan="5">
                            
                    <!-- Begin Search -->
                    <xsl:call-template name="search"/>
                    <!-- End Search -->
                    
                    <!-- Begin Standard Links -->
                    <xsl:call-template name="stdlinks"/>
                    <!-- End Standard Links -->

                    <!-- Begin Department Links -->
                    <xsl:call-template name="deptlinks"/>
                    <!-- End Department Links -->

                </td>
                <td class="content" colspan="16">
                      <!-- Begin Title -->
                            <h1><xsl:apply-templates select="title"/></h1>
                      <!-- End Title -->

                      <!-- Begin Lead -->
                            <p> <!-- class lead? -->
                                <xsl:apply-templates select="abstract"/>
                            </p>
                      <!-- End Lead -->

                      <!-- Begin content -->
                      <xsl:apply-templates select="body"/><br />
                      <!-- End content -->
                    
                      <!-- Begin footer -->
                      <div class="footer">
                            <xsl:call-template name="metafooter"/>
                            <xsl:call-template name="copyfooter"/>
                      </div>
                      <!-- End footer -->
    
                 </td>
            </tr>
        </table>

</body>
</html>
</xsl:template>


<xsl:template name="search">
        <form class="qsearch">
        <table cellpadding="0" cellspacing="0" border="0" width="128" >
            <tr>
                <td>
                      <input class="qsfield" type="text" name="search" size="6" value="[Schnellsuche]"/>
                </td>
                <td>
                      <img src="/images/icons/search_go.gif" width="24" height="11" border="0" alt="" />
                </td>
             </tr>
            </table>
    </form>
</xsl:template>


<xsl:template name="stdlinks">
        <p class="stdlinks" style="color:#123853; text-decoration:underline;">
        iPoint<br />
        WebMail<br />
        Druckansicht<br />
        Nur Text
    </p>
</xsl:template>


<xsl:template name="deptlinks">
        <p class="deptlinks" style="color:#123853; text-decoration:underline;">
        Navigationslinks
        </p>
</xsl:template>


<xsl:template match="a">
    <span class="pseudolink"><xsl:value-of select="text()"/></span>
</xsl:template>


<xsl:template name="header">
    <xsl:param name="no_navigation_at_all">false</xsl:param> 
    <tr>
        <td height="24" rowspan="2" class="bluebg"><xsl:text>&#160;</xsl:text></td>
        <td height="24" class="bluebg" colspan="11"><!--<img src="/images/today.png"/>--><xsl:text>&#160;</xsl:text></td>
        <td height="81" colspan="9" rowspan="4" valign="top"><img src="/images/icons/header_emotion_image.gif" alt="emotion bild" width="180" height="81" /></td>
    </tr>
    <tr>
        <td colspan="11" valign="top"><img src="/images/icons/header_05.gif" alt="Platzhalter" width="557" height="37" /></td>
    </tr>
    <tr>
        <td rowspan="2" valign="top"><img src="/images/icons/header_06.gif" alt="Platzhalter" width="53" height="20" /></td>
        <td valign="top"><img src="/images/icons/header_07.gif" alt="Platzhalter" width="15" height="17" /></td>
        <td valign="top"><img src="/images/icons/header_facts.gif" alt="" width="48" height="17" id="facts" name="facts" border="0"/></td>
        <td valign="top"><img src="/images/icons/header_09.gif" alt="Platzhalter" width="10" height="17" /></td>
        <td valign="top"><img src="/images/icons/header_service.gif" alt="" width="46" height="17" border="0"/></td>
        <td valign="top"><img src="/images/icons/header_11.gif" alt="Platzhalter" width="13" height="17" /></td>
        <td valign="top"><img src="/images/icons/header_faculty.gif" alt="" width="67" height="17" border="0"/></td>
        <td valign="top"><img src="/images/icons/header_13.gif" alt="Platzhalter" width="13" height="17" /></td>
        <td valign="top"><img src="/images/icons/header_studying.gif" alt="" width="54" height="17" border="0"/></td>
        <td valign="top"><img src="/images/icons/header_15.gif" alt="Platzhalter" width="13" height="17" /></td>
        <td valign="top"><img src="/images/icons/header_research.gif" alt="" width="63" height="17" border="0"/></td>
        <td rowspan="2" valign="top"><img src="/images/icons/header_17.gif" alt="Platzhalter" width="215" height="20" /></td>
    </tr>
    <tr>
        <td colspan="10" valign="top"><img src="/images/icons/header_18.gif" alt="Platzhalter" width="342" height="3" /></td>
    </tr>
    <tr>
        <td rowspan="2" valign="top"><img src="/images/icons/header_06a.gif" alt="Platzhalter" width="53" height="24" /></td>
        <td class="pathbg" rowspan="2" colspan="11"> 
                   <xsl:apply-templates select="/document/context/object/parents/object[position() != 1]">
                       <xsl:with-param name="no_navigation_at_all" select="$no_navigation_at_all" />
                   </xsl:apply-templates>
        </td>
        <td rowspan="2" valign="top"><img src="/images/icons/header_20.gif" alt="Platzhalter" width="44" height="24" /></td>
        <td colspan="7" valign="top"><img src="/images/icons/header_21.gif" alt="Platzhalter" width="104" height="4" /></td>
        <td rowspan="3" valign="top"><img src="/images/icons/header_uni_logo.gif" alt="" width="32" height="52" border="0"/></td>
    </tr>
    <tr>
        <td valign="top"><img src="/images/icons/header_site_map.gif" alt="" width="20" height="20" /></td>
        <td valign="top"><img src="/images/icons/header_24.gif" alt="header_24.gif" width="8" height="20" /></td>
        <td valign="top"><img src="/images/icons/header_search.gif" alt="" width="20" height="20" border="0"/></td>
        <td valign="top"><img src="/images/icons/header_26.gif" alt="header_26.gif" width="8" height="20" /></td>
        <td valign="top"><img src="/images/icons/header_language.gif" alt="" width="20" height="20" id="language" name="language" /></td>
        <td valign="top"><img src="/images/icons/header_28.gif" alt="header_28.gif" width="8" height="20" /></td>
        <td valign="top"><img src="/images/icons/header_contact.gif" alt="" width="20" height="20" border="0"/></td>
    </tr>
    <tr>
        <td colspan="12" valign="top">
        </td>
        <td colspan="8" valign="top"><img src="/images/icons/header_32.gif" alt="Platzhalter" width="148" height="28" /></td>
    </tr>
</xsl:template>


<xsl:template name="copyfooter">
    <p class="copy">
          © 2000 - 2002 Universität Innsbruck - Alle Rechte vorbehalten <br />
          <span class="pseudolink">Hilfe</span> | <span class="pseudolink">Mail an Webmaster</span>    
   </p>
</xsl:template>


</xsl:stylesheet>
