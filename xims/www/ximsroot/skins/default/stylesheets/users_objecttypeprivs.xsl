<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: users_objecttypeprivs.xsl 2246 2009-08-06 11:52:16Z haensel $
-->
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns:dyn="http://exslt.org/dynamic"
                xmlns="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="dyn">

    <xsl:import href="common.xsl"/>
    <xsl:import href="users_common.xsl"/>

    <xsl:param name="name"/>

    <xsl:variable name="root" select="/"/>
    <xsl:variable name="non_grouped_davots">
        <xsl:for-each
            select="/document/object_types/object_type[
        is_davgetable = 1 and name != 'Document' and
        name != 'DepartmentRoot' and name != 'File' and name != 'Folder' and
        name != 'Image' and name != 'SiteRoot' and name != 'CSS' and name != 'JavaScript' and name != 'Text' and
        name != 'AxPointPresentation' and name != 'DocBookXML' and name != 'XML' and
        name != 'XSLStylesheet' and name != 'XSPScript' and name != 'sDocBookXML']">
            <xsl:sort
                select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                order="ascending"/>
            <xsl:copy>
                <xsl:copy-of select="@*|*"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>


	<xsl:template match="/document">
		<html>
			<xsl:call-template name="head_default">
				<xsl:with-param name="mode">user</xsl:with-param>
			</xsl:call-template>
			<body>
				<xsl:call-template name="header">
					<xsl:with-param name="noncontent">true</xsl:with-param>
				</xsl:call-template>

				<div id="content-container">
					<h1 class="bluebg"><xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of select="$i18n_users/l/Objecttypeprivs"/>&#160;<xsl:value-of select="$i18n/l/of"/>&#160;<xsl:value-of select="$userquery"/></h1>
					<div id="op_create">
						<xsl:call-template name="objecttypeprivlist"/>
					</div>    
					<div id="op_webdav">
							<xsl:call-template name="dav_otprivileges"/>
					</div>
					<br class="clear"/>
					<a class="button" href="{$xims_box}{$goxims}/users?sort-by={$sort-by};order-by={$order-by};userquery={$userquery}"><xsl:value-of select="$i18n/l/cancel"/></a>
				</div>
				<xsl:call-template name="script_bottom"/>
			</body>
		</html>
	</xsl:template>

    <xsl:template name="objecttypeprivlist">

        <h2><xsl:value-of select="$i18n_users/l/Objecttypeprivs_objectCreation"/></h2>
        <xsl:if test="/document/objecttypelist/object_type[grantee_id = $name]">
            <h3><xsl:value-of select="$i18n_users/l/Explicit_pl"/>&#160;<xsl:value-of select="$i18n_users/l/Objecttypeprivs"/></h3>
            <ul>
                <xsl:apply-templates
                    select="/document/objecttypelist/object_type[grantee_id = $name]" mode="delete"
                />
            </ul>
        </xsl:if>
				<br/>
        <xsl:if test="/document/objecttypelist/object_type[grantee_id != $name]">
            <h3><xsl:value-of select="$i18n_users/l/Implicit_pl"/>&#160;(<xsl:value-of select="$i18n/l/Role"/>) <xsl:value-of select="$i18n_users/l/Objecttypeprivs"/></h3>
            <ul>
                <xsl:apply-templates
                    select="/document/objecttypelist/object_type[grantee_id != $name]"/>
            </ul>
        </xsl:if>
        
        <br/>
        <xsl:if test="/document/objecttypelist/object_type[not(can_create)]">
            <h3>
                <xsl:value-of select="$i18n_users/l/Add_objecttypepriv"/>
            </h3>
            <form name="create_objecttypepriv" action="{$xims_box}{$goxims_users}" method="get">
            <label for="op-select-ot"><xsl:value-of select="$i18n/l/Objecttype"/> :</label>
                <select name="objtype" id="op-select-ot">
                    <xsl:apply-templates select="/document/objecttypelist/object_type[not(can_create)]" mode="option"/>
                </select>
                <xsl:text>&#160;</xsl:text>
                <button name="addpriv" type="submit" title="{$i18n/l/Create}" class="button"><xsl:value-of select="$i18n/l/Create"/></button>
                <input name="objecttypeprivs" type="hidden" value="1"/>
                <input name="name" type="hidden" value="{$name}"/>
                <input name="sort-by" type="hidden" value="{$sort-by}"/>
                <input name="order-by" type="hidden" value="{$order-by}"/>
                <input name="userquery" type="hidden" value="{$userquery}"/>
            </form>
        </xsl:if>
        <br/><br/>
    </xsl:template>

    <xsl:template match="object_type">
        <xsl:variable name="parent_id" select="parent_id"/>
        <xsl:variable name="fullname">
            <xsl:choose>
                <xsl:when test="$parent_id != ''">
                    <xsl:value-of select="/document/objecttypelist/object_type[@id=$parent_id]/name"
                        />::<xsl:value-of select="name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>
            <xsl:value-of select="$fullname"/>
        </li>
    </xsl:template>

    <xsl:template match="object_type" mode="delete">
        <xsl:variable name="parent_id" select="parent_id"/>
        <xsl:variable name="fullname">
            <xsl:choose>
                <xsl:when test="$parent_id != ''">
                    <xsl:value-of select="/document/objecttypelist/object_type[@id=$parent_id]/name"
                        />::<xsl:value-of select="name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>
            <xsl:value-of select="$fullname"/>&#160;       
				    <a class="option-delete ui-button ui-widget ui-corner-all ui-button-icon-only ui-state-default" title="{$l_delete}" href="{$xims_box}{$goxims}/users?name={$name};objecttypeprivs=1;delpriv=1;grantor_id={grantor_id};object_type_id={@id};sort-by={$sort-by};order-by={$order-by};userquery={$userquery}">
             <xsl:attribute name="title"><xsl:value-of select="$i18n/l/delete"/></xsl:attribute>
             <span class="ui-button-icon-primary ui-icon xims-sprite sprite-option_delete"><xsl:comment/></span>
             <span class="ui-button-text"><xsl:value-of select="$i18n/l/delete"/>&#160;</span>
            </a>
        </li>
    </xsl:template>

    <xsl:template match="object_type" mode="option">
        <xsl:variable name="parent_id" select="parent_id"/>
        <xsl:variable name="fullname">
            <xsl:choose>
                <xsl:when test="$parent_id != ''">
                    <xsl:value-of select="/document/objecttypelist/object_type[@id=$parent_id]/name"
                        />::<xsl:value-of select="name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <option value="{$fullname}">
            <xsl:value-of select="$fullname"/>
        </option>
    </xsl:template>

    <xsl:template name="dav_otprivileges">
        <h2>
            <xsl:value-of select="$i18n_users/l/DAV_OTPrivileges"/>
        </h2>
        <form name="dav_ot_privs" action="{$xims_box}{$goxims_users}" method="get">
            <input name="objecttypeprivs" type="hidden" value="1"/>
            <input name="name" type="hidden" value="{$name}"/>
            <input name="sort-by" type="hidden" value="{$sort-by}"/>
            <input name="order-by" type="hidden" value="{$order-by}"/>
            <input name="userquery" type="hidden" value="{$userquery}"/>

                                    <span class="cboxitem">
                                        <input type="checkbox" name="dav_otprivs_Folder" class="checkbox" id="op-cb-bin">
                                          <xsl:if test="/document/context/user/dav_otprivileges/Folder = 1">
                                            <xsl:attribute name="checked">checked</xsl:attribute>
                                          </xsl:if>
                                        </input>
                                        <label for="op-cb-bin"><xsl:value-of select="$i18n_users/l/DAV_Container_Binary"/></label>
                                    </span>

                                    <span class="cboxitem">
                                        <input type="checkbox" name="dav_otprivs_Text" class="checkbox" id="op-cb-text">
                                            <xsl:if test="/document/context/user/dav_otprivileges/Text = 1">
                                                <xsl:attribute name="checked">checked</xsl:attribute>
                                            </xsl:if>
                                        </input>
                                        <label for="op-cb-text"><xsl:value-of select="$i18n_users/l/DAV_Text"/></label>
                                    </span>
                                <br/>
                                
                                    <span class="cboxitem">
                                        <input type="checkbox" name="dav_otprivs_XML" class="checkbox" id="op-cb-xml">
                                           <xsl:if test="/document/context/user/dav_otprivileges/XML = 1">
                                                <xsl:attribute name="checked">checked</xsl:attribute>
                                            </xsl:if>
                                        </input>
                                        <label for="op-cb-xml"><xsl:value-of select="$i18n_users/l/DAV_XML"/></label>
                                    </span>

                                    <span class="cboxitem">
                                        <input type="checkbox" name="dav_otprivs_Document" class="checkbox" id="op-cb-doc">
                                            <xsl:if test="/document/context/user/dav_otprivileges/Document = 1">
                                                <xsl:attribute name="checked">checked</xsl:attribute>
                                            </xsl:if>
                                        </input> <label for="op-cb-doc">Document</label></span>
                                <br/>
                            <xsl:call-template name="dav_ot_tr"/>

 <br class="clear"/>
 <br/>
 <p>
            <button type="submit" name="dav_otprivs_update" value="Update" class="button"><xsl:value-of select="$i18n/l/update"/></button>
            </p>
        </form>
    </xsl:template>

    <xsl:template name="dav_ot_tr">
        <xsl:for-each select="exslt:node-set($non_grouped_davots)/object_type[position() mod 2 = 1]">
           
                <xsl:apply-templates
                    select=". | following-sibling::object_type[position() &lt; 2]" mode="dav"/>
             <br/>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="object_type" mode="dav">
        <xsl:variable name="otxpath"
            select="concat('$root/document/context/user/dav_otprivileges/',name,'=1')"/>
            <span class="cboxitem">
                <input type="checkbox" name="dav_otprivs_{name}" class="checkbox" id="op-cb-{name}">
                    <xsl:if test="dyn:evaluate($otxpath)">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                </input>
                <label for="op-cb-{name}"><xsl:value-of select="name"/></label>
            </span>
    </xsl:template>
    
    <xsl:template name="title-userpage"><xsl:value-of select="$i18n_users/l/Managing"/>&#160;<xsl:value-of select="$i18n/l/Users"/>&#160;<xsl:value-of select="$i18n/l/Roles"/>&#160;</xsl:template>


</xsl:stylesheet>
