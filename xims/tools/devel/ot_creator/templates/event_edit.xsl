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
    &lt;xsl:output method=&quot;html&quot; encoding=&quot;utf-8&quot; media-type=&quot;text/html&quot; doctype-system=&quot;http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd&quot; doctype-public=&quot;-//W3C//DTD XHTML 1.0 Transitional//EN&quot; indent=&quot;no&quot;/&gt;

&lt;xsl:template match=&quot;/document/context/object&quot;&gt;
&lt;html&gt;
    &lt;xsl:call-template name=&quot;head-edit&quot;/&gt;
    &lt;body&gt;
        &lt;div class=&quot;edit&quot;&gt;
            &lt;xsl:call-template name=&quot;table-edit&quot;/&gt;
            &lt;form action=&quot;{$xims_box}{$goxims_content}{$absolute_path}&quot; method=&quot;POST&quot; name=&quot;eform&quot;&gt;
                &lt;table border=&quot;0&quot; width=&quot;98%&quot;&gt;
                    &lt;xsl:call-template name=&quot;tr-locationtitle-edit_xml&quot;/&gt;
                    &lt;xsl:call-template name=&quot;tr-body-edit&quot;/&gt;
                    &lt;xsl:call-template name=&quot;tr-keywords-edit&quot;/&gt;
                    &lt;xsl:call-template name=&quot;tr-abstract-edit&quot;/&gt;
                    &lt;xsl:call-template name=&quot;markednew&quot;/&gt;
                &lt;/table&gt;
                &lt;xsl:call-template name=&quot;saveedit&quot;/&gt;
            &lt;/form&gt;
        &lt;/div&gt;
        &lt;br /&gt;
        &lt;xsl:call-template name=&quot;canceledit&quot;/&gt;
    &lt;/body&gt;
&lt;/html&gt;
&lt;/xsl:template&gt;
&lt;/xsl:stylesheet&gt;
</xsl:text>
</xsl:template>
</xsl:stylesheet>
