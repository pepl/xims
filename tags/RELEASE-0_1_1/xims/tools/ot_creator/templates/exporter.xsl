<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
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
# Copyright (c) 2002-2003 The XIMS Project.
# See the file &quot;LICENSE&quot; for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
--&gt;
&lt;xsl:stylesheet version=&quot;1.0&quot;
                xmlns:xsl=&quot;http://www.w3.org/1999/XSL/Transform&quot;&gt;
&lt;xsl:output method=&quot;xml&quot;/&gt;

&lt;xsl:template match=&quot;/document&quot;&gt;
    &lt;xsl:apply-templates select=&quot;context/object/body&quot;/&gt;
&lt;/xsl:template&gt;

&lt;xsl:template match=&quot;/document/context/object/body//*&quot;&gt;
    &lt;xsl:copy&gt;
        &lt;xsl:copy-of select=&quot;@*&quot;/&gt;
        &lt;xsl:apply-templates/&gt;
    &lt;/xsl:copy&gt;
&lt;/xsl:template&gt;
&lt;/xsl:stylesheet&gt;
</xsl:text>
</xsl:template>
</xsl:stylesheet>
