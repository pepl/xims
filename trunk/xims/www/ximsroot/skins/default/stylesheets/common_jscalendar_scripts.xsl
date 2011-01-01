<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="jscalendar_scripts">
    <!-- The DHTML / JavaScript Calendar © Dynarch.com, 2003-2005
         http://www.dynarch.com/projects/calendar/
    -->
    <link rel="stylesheet" type="text/css" media="all" href="{$ximsroot}jscalendar-1.0/calendar-blue.css" title="winter" />
    <script type="text/javascript" src="{$ximsroot}jscalendar-1.0/calendar.js"><xsl:text>&#160;</xsl:text></script>
    <script type="text/javascript">
        <xsl:attribute name="src">
            <xsl:value-of select="concat($ximsroot,'jscalendar-1.0/lang/calendar-',substring(/document/context/session/uilanguage,1,2),'.js')"/>
            <!-- If you are using the CVS version of XIMS and have downloaded jscalendar-1.0 by yourself
                 you have to add

                 // First day of the week. "0" means display Sunday first, "1" means display
                 // Monday first, etc.
                 Calendar._FD = 0;

                 after line 45 of lang/calendar-de.js
                 http://sourceforge.net/tracker/index.php?func=detail&amp;aid=1162371&amp;group_id=75569&amp;atid=544285
            -->
        </xsl:attribute>
        <xsl:text>&#160;</xsl:text>
    </script>
    <script type="text/javascript" src="{$ximsroot}jscalendar-1.0/calendar-setup.js"><xsl:text>&#160;</xsl:text></script>
</xsl:template>
</xsl:stylesheet>
