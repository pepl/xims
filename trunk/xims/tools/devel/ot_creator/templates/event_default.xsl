<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

<xsl:output method="xml"/>

<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/document"><xsl:text disable-output-escaping="yes">&lt;!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file &quot;LICENSE&quot; for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
--&gt;
&lt;xsl:stylesheet version=&quot;1.0&quot;
                xmlns:xsl=&quot;http://www.w3.org/1999/XSL/Transform&quot;
                xmlns=&quot;http://www.w3.org/1999/xhtml&quot;&gt;

&lt;xsl:import href=&quot;common.xsl&quot;/&gt;
&lt;xsl:output method=&quot;html&quot; encoding=&quot;utf-8&quot;/&gt;

&lt;xsl:template match=&quot;/document/context/object&quot;&gt;
    &lt;html&gt;
        &lt;xsl:call-template name=&quot;head_default&quot;/&gt;
        &lt;body margintop=&quot;0&quot; marginleft=&quot;0&quot; marginwidth=&quot;0&quot; marginheight=&quot;0&quot; background=&quot;{$ximsroot}skins/{$currentskin}/images/body_bg.png&quot;&gt;
            &lt;xsl:call-template name=&quot;header&quot;/&gt;
            &lt;table align=&quot;center&quot; width=&quot;98.7%&quot; style=&quot;border: 1px solid; margin-top: 0px; padding: 0.5px&quot;&gt;
                &lt;tr&gt;
                    &lt;td colspan=&quot;2&quot;&gt;
                        &lt;xsl:apply-templates select=&quot;body&quot;/&gt;
                    &lt;/td&gt;
                &lt;/tr&gt;
            &lt;/table&gt;
            &lt;table align=&quot;center&quot; width=&quot;98.7%&quot; class=&quot;footer&quot;&gt;
                &lt;xsl:call-template name=&quot;user-metadata&quot;/&gt;
                &lt;xsl:call-template name=&quot;footer&quot;/&gt;
            &lt;/table&gt;
        &lt;/body&gt;
    &lt;/html&gt;
&lt;/xsl:template&gt;
&lt;/xsl:stylesheet&gt;
</xsl:text>
</xsl:template>
</xsl:stylesheet>
