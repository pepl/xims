<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="../document_common.xsl"/>

<xsl:template name="without-wysiwyg">
    <a style="margin-left:18px;" href="{$goxims_content}{$absolute_path}?create=1;plain=1;objtype=Document;parid={@id}">Create without WYSIWYG-Editor</a>
</xsl:template>

<xsl:template name="edit-without-wysiwyg">
    <a style="margin-left:18px;" href="{$goxims_content}{$absolute_path}?edit=1;plain=1">Edit without WYSIWYG-Editor</a>
</xsl:template>

</xsl:stylesheet>
