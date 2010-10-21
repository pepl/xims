<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
  
  <xsl:import href="container_common.xsl"/>

  <xsl:param name="printview" select="'0'"/>

  <xsl:template name="table-create">
    <table border="0" 
           align="center" 
           width="98%" 
           cellpadding="0" 
           cellspacing="0">
      <tr>
        <td valign="top">
          <xsl:value-of select="$i18n/l/create"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$objtype"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$i18n/l/in"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$absolute_path"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$i18n/l/using"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:call-template name="setdefaulteditor"/>
        </td>
        <td align="right" valign="top">
          <xsl:call-template name="cancelcreateform">
            <xsl:with-param name="with_save">yes</xsl:with-param>
          </xsl:call-template>
        </td>
      </tr>
    </table>
  </xsl:template>
  
  <xsl:template name="table-edit">
    <table border="0" 
           align="center"
           width="98%" 
           cellpadding="0" 
           cellspacing="0">
      <tr>
        <td valign="top">
          <xsl:value-of select="$i18n/l/edit"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$objtype"/>
          <xsl:text>&#160;'</xsl:text>
          <xsl:value-of select="title"/>
          <xsl:text>'&#160;</xsl:text>
          <xsl:value-of select="$i18n/l/in"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$parent_path"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$i18n/l/using"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:call-template name="setdefaulteditor"/>
        </td>
        <td align="right" valign="top">
          <xsl:call-template name="cancelform">
            <xsl:with-param name="with_save">yes</xsl:with-param>
          </xsl:call-template>
        </td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template name="trytobalance">
    <tr>
      <td colspan="3">
        <xsl:value-of select="$i18n/l/Try_to_well-balance"/>
        <input name="trytobalance"
               type="radio" 
               value="true"
               checked="checked"
               onchange="javascript:createCookie('xims_trytobalancewell','true',90);"/>
        <xsl:value-of select="$i18n/l/Yes"/>
        <input name="trytobalance" 
               type="radio" 
               value="false"
               onchange="javascript:createCookie('xims_trytobalancewell','false',90);"/>
        <xsl:value-of select="$i18n/l/No"/>
        <!-- set checked attribute for trytobalance-input-element according to cookie -->
        <script type="text/javascript">
          <xsl:text>selTryToBalance(document.eform.trytobalance, readCookie('xims_trytobalancewell'));</xsl:text>
        </script>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="setdefaulteditor">
    <xsl:call-template name="mk-inline-js">
      <xsl:with-param name="code">
      <![CDATA[
      //    function which selects 'trytobalance' input form element to a
      //    given value (e.g. from cookie); see 'document_edit.xsl'
      function selTryToBalance(selElement, toSelect) {
          if ( !toSelect ) {
              toSelect = 'true';
          }   
          toSelect = toSelect.toLowerCase();
          for (var i=0; i < selElement.length; i++) {
              if ( selElement[i].value.toString().toLowerCase() == toSelect ) {
                  selElement[i].checked = true;
              }   
          }   
      }
 
      function createCookie(name,value,days) {
          if (days) {
              var date = new Date();
              date.setTime(date.getTime()+(days*24*60*60*1000));
              var expires = "; expires="+date.toGMTString();
          }
          else var expires = "";
          document.cookie = name+"="+value+expires+"; path=/";
      }

      function readCookie(name) {
          var nameEQ = name + "=";
          var ca = document.cookie.split(';');
          for (var i=0;i < ca.length;i++) {
              var c = ca[i];
              while (c.charAt(0)==' ') c = c.substring(1,c.length);
              if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
          }
          return null;
      }
      
      function setSel(selObj, toselect) {
          if ( !toselect ) {
              if ( window.tinyMCE ) {
                  toselect = 'tinymce';
              }
              else {
                  toselect = 'plain';
              }
          }
          toselect = toselect.toLowerCase();
          opts=selObj.options,
          i=opts.length;
          while (i-->0) {
              if(opts[i].value.toLowerCase()==toselect) {
                  selObj.selectedIndex=i;
                  return true;
              }
          }
          return false;
      }

      function checkBodyFromSel (selection) {

          createCookie('xims_wysiwygeditor',selection,90);

          if ( hasBodyChanged() ) {
              document.getElementById('xims_wysiwygeditor').disabled = true;
              alert("]]><xsl:value-of select="$i18n/l/Body_content_changed"/><![CDATA[");
              return false;
          }

	  // reload with param 'true' in order to fetch (clean) content from
	  // server again; this interfears the least with JS-WYSIWYG editors 
        
          window.location.reload(true);

          return true;
      }

      function hasBodyChanged () {
          var currentbody;
          // check for TinyMCE editor content
          if (window.tinyMCE){
              currentbody = tinyMCE.get('body').getContent();
          }
          // Plain Textarea
          else {
              var body = document.getElementById('body');
              if ( body && body.value ) {
                  currentbody = body.value;
              }
          }

          // now lets check if there are any changes ;-)
          if ( currentbody && currentbody != origbody ) {
              return true;
          }
          // return false otherwise
          else {
              return false;
          }
      }
    /*    Disable possibility of changing WYSIWYG editors for "timeout"
          seconds. This prevents false-positive errors of "hasBodyChanged()"
          due to switching to another editor too fast.
     */
      function timeoutWYSIWYGChange(timeout) {
          document.getElementById('xims_wysiwygeditor').disabled = true;
          window.setTimeout("document.getElementById('xims_wysiwygeditor').disabled = false;",timeout*1000);
      } ]]>
      </xsl:with-param>
    </xsl:call-template>
    <form name="editor_selector" 
          id="editor_selector" 
          action=""
          style="display: inline; margin: 0px;">
      <select style="font-size: 9px; padding: 0px; background-color: #eeeeee;" 
              name="xims_wysiwygeditor" 
              id="xims_wysiwygeditor" 
              onchange="javascript:return checkBodyFromSel(this.value);">
        <xsl:copy-of select="$editoroptions" />
      </select>
    </form>
    <script type="text/javascript">
      setSel(document.getElementById('xims_wysiwygeditor'), readCookie('xims_wysiwygeditor'));
    </script>
  </xsl:template>
  

  <xsl:template name="document-options">
    <tr>
      <td colspan="2">
        <a href="javascript:previewWindow('{$xims_box}{$goxims_content}{$absolute_path}?pub_preview=1')">
          <xsl:value-of select="$i18n/l/Publishingpreview"/>
        </a>
        <img style="margin-left: 2px" 
             src="{$ximsroot}images/icons/opens_new_window.gif" 
             width="11" 
             height="11" 
             border="0" 
             alt="opens_in_new_window" 
             title="{$i18n/l/Opens_in_new_window}"/>
        <xsl:if test="children/object[location='.diff_to_second_last']">
          &#xa0;
          <a href="javascript:diffWindow('{$xims_box}{$goxims_content}{$absolute_path}/.diff_to_second_last?bodyonly=1;pre=1')">
            <xsl:value-of select="$i18n/l/See_changes_latest_edit"/>
          </a>
          <img style="margin-left: 2px" 
               src="{$ximsroot}images/icons/opens_new_window.gif" 
               width="11" 
               height="11" 
               border="0" 
               alt="opens_in_new_window" 
               title="{$i18n/l/Opens_in_new_window}"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>
  

  <xsl:template match="children/object" 
                mode="link">

    <xsl:variable name="dataformat">
      <xsl:value-of select="data_format_id"/>
    </xsl:variable>
   
    <xsl:variable name="objecttype">
      <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    
    <xsl:if test="/document/data_formats/data_format[@id=$dataformat]/name='URL' 
               or /document/data_formats/data_format[@id=$dataformat]/name='SymbolicLink'">
      <tr>
        <td width="30">
          <xsl:call-template name="cttobject.status"/>
        </td>
        <td align="center">
          <xsl:call-template name="cttobject.position"/>
        </td>
        <td>
          <a>
            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
                  <xsl:value-of select="location"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($goxims_content,symname_to_doc_id,'?sb=',$sb,';order=',$order,';m=',$m)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="title" />
          </a>
        </td>
        <xsl:if test="$m='e'">
          <td align="right">
            <xsl:choose>
              <xsl:when test="marked_deleted != '1' 
                          and user_privileges/write 
                          and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                <a href="{$goxims_content}?id={@id};edit=1">
                  <img src="{$skimages}option_edit.png"
                       alt="{$l_Edit}"
                       title="{$l_Edit}"
                       border="0"
                       onmouseover="pass('edit{@document_id}','edit','h'); return true;"
                       onmouseout="pass('edit{@document_id}','edit','c'); return true;"
                       onmousedown="pass('edit{@document_id}','edit','s'); return true;"
                       onmouseup="pass('edit{@document_id}','edit','s'); return true;"
                       name="edit{@document_id}"
                       width="32"
                       height="19"
                       align="left"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <img src="{$ximsroot}images/spacer_white.gif"
                     width="32"
                     height="19"
                     border="0"
                     alt=" "
                     align="left"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="marked_deleted != '1' 
                          and (user_privileges/publish|user_privileges/publish_all) 
                          and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                <a href="{$goxims_content}?id={@id};publish_prompt=1">
                  <img src="{$skimages}option_pub.png"
                       border="0"
                       alt="{$i18n/l/Publishing_options}"
                       title="{$i18n/l/Publishing_options}"
                       name="publish{@document_id}"
                       width="32"
                       height="19"
                       align="left"
                       />
                </a>
              </xsl:when>
              <xsl:otherwise>
                <img src="{$ximsroot}images/spacer_white.gif"
                     border="0"
                     width="32"
                     height="19"
                     alt=""
                     align="left"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="user_privileges/grant|user_privileges/grant_all">
                <a href="{$goxims_content}?id={@id};obj_acllist=1">
                  <img src="{$skimages}option_acl.png"
                       border="0"
                       alt="{$i18n/l/Access_control}"
                       title="{$i18n/l/Access_control}"
                       align="left"
                       width="32"
                       height="19"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <img src="{$ximsroot}images/spacer_white.gif"
                     width="32"
                     height="19"
                     border="0"
                     alt=""
                     align="left"
                     />
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="user_privileges/delete and published != '1' 
                              and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                <a class="xims-sprite sprite-option_purge" title="{$i18n/l/purge}" href="{$goxims_content}?id={@id};delete_prompt=1">
				          &#xa0;<span><xsl:value-of select="$i18n/l/purge"/></span>
				        </a>
              </xsl:when>
              <xsl:otherwise>
                <img src="{$ximsroot}images/spacer_white.gif" 
                     width="37"
                     height="19" 
                     border="0" 
                     alt="" 
                     align="left"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </xsl:if>
      </tr>
    </xsl:if>
  </xsl:template>  

  <xsl:template match="children/object" 
                mode="comment">

    <xsl:variable name="objecttype">
      <xsl:value-of select="object_type_id"/>
    </xsl:variable>

    <!-- <xsl:if test="/document/object_types/object_type[@id=$objecttype]/name='Annotation'"> -->
    <!--
        pepl: This hardcoded OT would not be neccessary if the Annotations would be loaded via -getchildren!!!
        (I guess its time to change the "definition" regarding Annotations and their granted privs)
    -->
    
    <xsl:if test="$objecttype=16">
      <tr>
        <td colspan="3">
          <img src="{$ximsroot}images/spacer_white.gif" 
               alt="" 
               width="{10*@level}"
               height="10"/>
          <img src="{$ximsroot}images/icons/list_HTML.gif" 
               alt="" 
               width="20" 
               height="18"/>
          <a href="{$goxims_content}{$absolute_path}?id={@document_id};view=1;m={$m}">
            <xsl:value-of select="title"/>
          </a>
          by <xsl:call-template name="creatorfullname"/>
        </td>
      </tr>
      <tr>
        <td width="96%">
          <img src="{$ximsroot}images/spacer_white.gif" 
               alt="" 
               width="{10*@level+20}" 
               height="10"/>
          <xsl:apply-templates select="last_modification_timestamp" 
                               mode="datetime"/>
        </td>
        <xsl:if test="$m='e'">
          <td width="2%">
            <xsl:choose>
              <xsl:when test="/document/context/object/user_privileges/write 
                          and locked_time = '' 
                          or locked_by = /document/session/user/@id">
                <a href="{$goxims_content}?id={@id};edit=1">
                  <img src="{$skimages}option_edit.png"
                       border="0"
                       alt="Bearbeiten"
                       title="Dieses Objekt bearbeiten"
                       width="32" height="19"
                       align="left"
                       onmouseover="pass('edit{@document_id}','edit','h'); return true;"
                       onmouseout="pass('edit{@document_id}','edit','c'); return true;"
                       onmousedown="pass('edit{@document_id}','edit','s'); return true;"
                       onmouseup="pass('edit{@document_id}','edit','c'); return true;"
                       name="edit{@document_id}"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <img src="{$ximsroot}images/spacer_white.gif"
                     width="32"
                     height="19"
                     border="0"
                     alt=""
                     align="left"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td width="2%">
            <xsl:choose>
              <xsl:when test="user_privileges/delete 
                          and published != '1' 
                          and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                <form style="margin:0px;" name="delete"
                      method="get"
                      action="{$xims_box}{$goxims_content}">
                  <input type="hidden" 
                         name="delete_prompt" 
                         value="1"/>
                  <input type="hidden" 
                         name="id" 
                         value="{@id}"/>
                  <input type="image"
                         name="del{@id}"
                         src="{$skimages}option_purge.png"
                         border="0"
                         width="37"
                         height="19"
                         alt="{$i18n/l/purge}"
                         title="{$i18n/l/purge}"/>
                </form>
              </xsl:when>
              <xsl:otherwise>
                <img src="{$ximsroot}images/spacer_white.gif" 
                     width="37" 
                     height="19" 
                     border="0" 
                     alt="" 
                     align="left" />
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </xsl:if>
      </tr>
    </xsl:if>
  </xsl:template>


  <xsl:template name="tr-locationtitle-edit_doc">
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <tr>
      <td valign="top">
        <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
        <span class="compulsory">
          <xsl:value-of select="$i18n/l/Location"/>
        </span>
      </td>
      <td>
        <!-- strip the suffix -->
        <input tabindex="10" type="text" name="name" size="40">
          <xsl:choose>
            <xsl:when test="published = '1'">
              <xsl:attribute name="readonly">readonly</xsl:attribute>
              <xsl:attribute name="class">readonlytext</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">text</xsl:attribute>
	      <xsl:attribute name="onfocus">this.className='text focused'</xsl:attribute>
	      <xsl:attribute name="onchange">this.className='text'; return testlocation();</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:attribute name="value">
            <xsl:value-of select="location"/>
          </xsl:attribute>
        </input>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
	<!-- we only test locations for unpublished docs -->
	<xsl:if test="not(published = '1')">
	    <xsl:call-template name="testlocationjs">
		<xsl:with-param name="event" select="'edit'"/>
		<xsl:with-param name="obj_type" select="/document/object_types/object_type[@id=$objecttype]/fullname"/>
	    </xsl:call-template>
	</xsl:if>
      </td>
      <td align="right" valign="top">
        <xsl:call-template name="marked_mandatory"/>
      </td>
    </tr>
    <xsl:call-template name="tr-title-edit"/>
  </xsl:template>


</xsl:stylesheet>
