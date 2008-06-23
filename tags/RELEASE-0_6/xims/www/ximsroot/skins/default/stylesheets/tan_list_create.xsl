<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
	
	<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

<xsl:template name="tr-tannumber-create">
<tr>
        <td valign="top"><span class="compulsory"><xsl:value-of select="$i18n_qn/l/TAN_number"/></span></td>
        <td colspan="2">
            <input tabindex="30" type="text" name="number" size="10" class="text"/>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
