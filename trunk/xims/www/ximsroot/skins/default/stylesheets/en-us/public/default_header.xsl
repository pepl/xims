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
        <td valign="top"><a href="http://www2.uibk.ac.at/fakten/" onmouseover="pass(&apos;facts&apos;,&apos;h&apos;); return true;" onmouseout="pass(&apos;facts&apos;,&apos;n&apos;); return true;" ><img src="/images/icons/header_facts.gif" alt="Informationen über die Universität Innsbruck, ihr Leitungsteam und ihr Umfeld" width="48" height="17" id="facts" name="facts" border="0"/></a></td>
        <td valign="top"><img src="/images/icons/header_09.gif" alt="Platzhalter" width="10" height="17" /></td>
        <td valign="top"><a href="http://www2.uibk.ac.at/service/" onmouseover="pass(&apos;service&apos;,&apos;h&apos;); return true;" onmouseout="pass(&apos;service&apos;,&apos;n&apos;); return true;"><img src="/images/icons/header_service.gif" alt="Dienstleistungen, Verwaltung und Interessenvertretungen" width="46" height="17" id="service" name="service" border="0"/></a></td>
        <td valign="top"><img src="/images/icons/header_11.gif" alt="Platzhalter" width="13" height="17" /></td>
        <td valign="top"><a href="http://www2.uibk.ac.at/fakultaeten/" onmouseover="pass(&apos;faculty&apos;,&apos;h&apos;); return true;" onmouseout="pass(&apos;faculty&apos;,&apos;n&apos;); return true;"><img src="/images/icons/header_faculty.gif" alt="Fakultäten und Institute" width="67" height="17" id="faculty" name="faculty" border="0"/></a></td>
        <td valign="top"><img src="/images/icons/header_13.gif" alt="Platzhalter" width="13" height="17" /></td>
        <td valign="top"><a href="http://www2.uibk.ac.at/studium/" onmouseover="pass(&apos;studying&apos;,&apos;h&apos;); return true;" onmouseout="pass(&apos;studying&apos;,&apos;n&apos;); return true;"><img src="/images/icons/header_studying.gif" alt="Informationen zu Studium, Studienplänen und Projekten" width="54" height="17" id="studying" name="studying" border="0"/></a></td>
        <td valign="top"><img src="/images/icons/header_15.gif" alt="Platzhalter" width="13" height="17" /></td>
        <td valign="top"><a href="http://www2.uibk.ac.at/forschung/" onmouseover="pass(&apos;research&apos;,&apos;h&apos;); return true;" onmouseout="pass(&apos;research&apos;,&apos;n&apos;); return true;"><img src="/images/icons/header_research.gif" alt="Forschungsdokumentation und Forschungsförderung" width="63" height="17" id="research" name="research" border="0"/></a></td>
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
        <td rowspan="3" valign="top"><a href="http://www2.uibk.ac.at/"><img src="/images/icons/header_uni_logo.gif" alt="Logo der Universität Innsbruck" width="32" height="52" border="0"/></a></td>
    </tr>
    <tr>
        <td valign="top"><!--<a href="" onmouseover="pass(&apos;site_map&apos;,&apos;h&apos;); return true;" onmouseout="pass(&apos;site_map&apos;,&apos;n&apos;); return true;"--><img src="/images/icons/header_site_map.gif" alt="Website Übersicht" width="20" height="20" id="site_map" /><!--</a>--></td>
        <td valign="top"><img src="/images/icons/header_24.gif" alt="header_24.gif" width="8" height="20" /></td>
        <td valign="top"><a href="http://www2.uibk.ac.at/suche/" onmouseover="pass(&apos;search&apos;,&apos;h&apos;); return true;" onmouseout="pass(&apos;search&apos;,&apos;n&apos;); return true;"><img src="/images/icons/header_search.gif" alt="Suche" width="20" height="20" id="search" name="search" border="0"/></a></td>
        <td valign="top"><img src="/images/icons/header_26.gif" alt="header_26.gif" width="8" height="20" /></td>
        <td valign="top"><img src="/images/icons/header_language.gif" alt="Es gibt keine englische Version dieses Dokuments" width="20" height="20" id="language" name="language" /></td>
        <td valign="top"><img src="/images/icons/header_28.gif" alt="header_28.gif" width="8" height="20" /></td>
        <td valign="top"><a href="http://www2.uibk.ac.at/kontakt/" onmouseover="pass(&apos;contact&apos;,&apos;h&apos;); return true;" onmouseout="pass(&apos;contact&apos;,&apos;n&apos;); return true;"><img src="/images/icons/header_contact.gif" alt="Kontaktinformationen" width="20" height="20" id="contact" name="contact" border="0"/></a></td>
    </tr>
    <tr>
        <td colspan="12" valign="top">
        </td>
        <td colspan="8" valign="top"><img src="/images/icons/header_32.gif" alt="Platzhalter" width="148" height="28" /></td>
    </tr>
</xsl:template>

</xsl:stylesheet>
