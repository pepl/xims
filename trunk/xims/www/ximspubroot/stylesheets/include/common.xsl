<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<!--$Id$-->
<xsl:import href="common-generic.xsl"/>

<xsl:template name="stdlinks">
    <div id="linkbox">
        <h3>xims.info</h3>
        <ul>
            <li title="Home"><a href="http://xims.info/">Home</a></li>
            <li title="About"><a href="http://xims.info/about.html">About</a></li>
            <li title="Documentation"><a href="http://xims.info/documentation/">Documentation</a></li>
            <li title="Screenshots"><a href="http://xims.info/screenshots/">Screenshots</a></li>
            <li title="Download"><a href="http://xims.info/download/">Download</a></li>
            <li title="Login"><a href="/goxims/user">Login</a></li>
        </ul>
    </div>
</xsl:template>

<xsl:template name="copyfooter">
    © 2002-2005 <a href="http://xims.info/">The XIMS Project</a>,<br/> <a href="http://www.uibk.ac.at/">University of Innsbruck</a>
</xsl:template>

<xsl:template name="powerdbyfooter">
    Powered by <a href="http://axkit.org/"><!--<img src="http://www.hampton.ws/skins/corporate/images/pb_axkit.gif" width="87" height="30" alt="Powered by AxKit" title="Powered by AxKit" border="0"/>-->AxKit</a>
    <xsl:text>&#160;&amp;&#160;</xsl:text>
    <a href="http://sourceforge.net">
        <img src="http://sourceforge.net/sflogo.php?group_id=42250" width="88" height="31" border="0" alt="SourceForge Logo"/>
    </a>
</xsl:template>

</xsl:stylesheet>
