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
<xsl:import href="common_contentbrowse_ewebeditimage.xsl"/>
<xsl:param name="id"/>
<xsl:param name="parid"/>

<xsl:template name="targetpath">
    <xsl:for-each select="/document/context/object/targetparents/object[@parent_id != 1]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

<xsl:template name="scripts">
    <script type="text/javascript">
      <![CDATA[
        var objQuery = new Object();
        var selectedText;
        var selectedHTML;
        var strQuery = location.search.substring(1);
        var aryQuery = strQuery.split(";");
        var pair = [];
        for (var i = 0; i < aryQuery.length; i++) {
            pair = aryQuery[i].split("=");
            if (pair.length == 2)
            {
                objQuery[unescape(pair[0])] = unescape(pair[1]);
            }

        }

        function loadselectedtext() {
            var testimage;
            if (document.selectform.linktext.value == '') {
                selectedText = window.opener.eWebEditPro[objQuery["editorName"]].getSelectedText();
                selectedHTML = window.opener.eWebEditPro[objQuery["editorName"]].getSelectedHTML();
                testimage = selectedHTML.substring(0, 4);
                if (testimage.toLowerCase() == "<img"){
                  document.selectform.linktext.value = selectedHTML;
                }
                else
                {
                  document.selectform.linktext.value = selectedText;
                }
            }
        }
        function inserthyperlink() {
            if (window.opener.closed) {
                alert("Your hyperlink could not be inserted because the editor page has been closed.");
            }
            else if (document.selectform.linktext.value == '') {
                alert("Your hyperlink text is blank and would create an empty link.");
            }
            else{
                var hyperlinkvalue;
                var pastevalue;
                var targetvalue;
                var targetvaluepaste
                targetvalue = document.selectform.Target.options[document.selectform.Target.selectedIndex].value;
                if (targetvalue == "") {
                    targetvaluepaste = "";
                }
                else {
                    targetvaluepaste = "target=" + targetvalue;
                }
                hyperlinkvalue = document.selectform.httpLink.value
                pastevalue = '<A HREF="' + hyperlinkvalue + '" ' + targetvaluepaste +'>' + document.selectform.linktext.value + '</a>';
                window.opener.eWebEditPro[objQuery["editorName"]].pasteHTML(pastevalue);
                window.close();
            }
        }
        function storeBack(target, linktext) {
      ]]>
            re = new RegExp("<xsl:choose><xsl:when test="$parid=''"><xsl:value-of select="$parent_path_nosite"/></xsl:when><xsl:otherwise><xsl:value-of select="$absolute_path_nosite"/></xsl:otherwise></xsl:choose>/");
      <![CDATA[
            re.test(target);
            if (RegExp.rightContext.length > 0) {
                document.selectform.httpLink.value=RegExp.rightContext;
            }
            else {
      ]]>
                document.selectform.httpLink.value=target;
      <![CDATA[
            }
            document.selectform.linktext.value=linktext;
        }
      ]]>
    </script>
</xsl:template>

</xsl:stylesheet>
