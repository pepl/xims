<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: anondiscussionforum_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="anondiscussionforum_common.xsl"/>

<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default"/>
    <body>
        <xsl:call-template name="header"/>
        
        <div id="main-content">
						<xsl:call-template name="options-menu-bar"/>
						<div id="content-container" class="ui-corner-bottom ui-corner-tr">
							<div id="docbody">
                        <span id="body">
                            <!--<xsl:apply-templates select="body"/>-->
                            <h1 class="documenttitle"><xsl:value-of select="title" /></h1>

        <p>
            <strong><xsl:apply-templates select="abstract"/></strong>
        </p>

        <br />

        <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="get">
        <input type="hidden" name="objtype" value="AnonDiscussionForumContrib"/>
            <xsl:if test="user_privileges/create">
                <!--<input type="submit" name="create" value="{$i18n/l/Create_topic}" class="control" /><br /><br />-->
                <button type="submit" name="create" class="ui-state-default ui-corner-all fg-button" >
									<xsl:value-of select="$i18n/l/Create_topic"/>
                </button>
            </xsl:if>
        </form>
			<br /><br />
				
				<!--<xsl:variable name="topics"><xsl:value-of select="count(children/object)"/></xsl:variable>-->
				<xsl:if test="count(children/object)">
        <xsl:call-template name="forumtable"/>
                       
				</xsl:if>
				 </span>
							</div>
           <div id="metadata-options">
							<div id="user-metadata">
								<xsl:call-template name="user-metadata"/>
							</div>
							<div id="document-options">
<!--								<xsl:call-template name="document-options"/>-->
							</div>
						</div>
					</div>
				</div>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="forumtable">
                    <table id="obj-table">
											<thead>
                        <tr>
                            <th id="th-topic" class="sorting">
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb=name&amp;order=desc" class="th-icon-right">
                                <span class="ui-icon ui-icon-triangle-1-n"/>
                                    <xsl:value-of select="$i18n/l/Topic"/>
                                </a>
                            </th>
                            <th id="th-created" class="sorting" nowrap="nowrap">
                                <a href="?sb=date" class="th-icon-right">
																	<span class="ui-icon ui-icon-triangle-1-n"/>
                                    <xsl:value-of select="$i18n/l/Created"/>
                                </a>
                            </th>
                            <th id="th-author" width="134"><xsl:value-of select="$i18n/l/Author"/></th>
                            <th id="th-replies" width="50"><xsl:value-of select="$i18n/l/Replies"/></th>
                            <th id="th-lastreply" width="134"><xsl:value-of select="$i18n/l/Last_reply"/></th>
                        </tr>
                        			</thead>
											<tbody>
                        <!--<xsl:apply-templates select="children/object">-->
                        <xsl:choose>
													<xsl:when test="$sb='name'">
														<xsl:choose>
															<xsl:when test="$order='asc'">
															<xsl:apply-templates select="children/object">
																<xsl:sort select="title" order="ascending" case-order="lower-first"/>
																</xsl:apply-templates>
															</xsl:when>
															<xsl:when test="$order='desc'">
															<xsl:apply-templates select="children/object">
																<xsl:sort select="title" order="descending"/>
																</xsl:apply-templates>
															</xsl:when>
                           </xsl:choose>
                           </xsl:when>
                           <xsl:when test="$sb='date' or $sb='position'">
														 <xsl:choose>
															<xsl:when test="$order='asc'">
																<xsl:apply-templates select="children/object">
																<xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="ascending"/>
																</xsl:apply-templates>
															</xsl:when>
															<xsl:when test="$order='desc'">
															<xsl:apply-templates select="children/object">
																<xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="descending"/>
															</xsl:apply-templates>
															</xsl:when>
														 </xsl:choose>
														 </xsl:when>
														 </xsl:choose>
                        </tbody>
                    </table>
</xsl:template>

<!--<xsl:template name="forumtable">
    <xsl:choose>
--><!-- begin sort by name --><!--
        <xsl:when test="$sb='name'">
            <xsl:choose>
                <xsl:when test="$order='asc'">
                    <table class="10left" border="0" cellpadding="3" cellspacing="0" width="800">
                        <tr>
                            <td class="lightblue">
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb=name&amp;order=desc">
                                    <xsl:value-of select="$i18n/l/Topic"/>
                                    <img src="{$skimages}arrow_ascending.gif" width="10" height="10" border="0" alt="sort descending"/>
                                </a>
                            </td>
                            <td class="lightblue" width="120" nowrap="nowrap">
                                <a href="?sb=date">
                                    <xsl:value-of select="$i18n/l/Created"/>
                                </a>
                            </td>
                            <td class="lightblue" width="134"><xsl:value-of select="$i18n/l/Author"/></td>
                            <td class="lightblue" width="50"><xsl:value-of select="$i18n/l/Replies"/></td>
                            <td class="lightblue" width="134"><xsl:value-of select="$i18n/l/Last_reply"/></td>
                            <td></td>
                        </tr>
                        <xsl:apply-templates select="children/object">
                            <xsl:sort select="title" order="ascending" case-order="lower-first"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
                <xsl:when test="$order='desc'">
                    <table class="10left" border="0" cellpadding="3" cellspacing="0" width="800">
                        <tr>
                            <td class="lightblue">
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?sb=name&amp;order=asc">
                                    <xsl:value-of select="$i18n/l/Topic"/>
                                    <img src="{$skimages}arrow_descending.gif" width="10" height="10" border="0" alt="sort ascending"/>
                                </a>
                            </td>
                            <td class="lightblue" width="120" nowrap="nowrap">
                                <a href="?sb=date">
                                    <xsl:value-of select="$i18n/l/Created"/>
                                </a>
                            </td>
                            <td class="lightblue" width="134"><xsl:value-of select="$i18n/l/Author"/></td>
                            <td class="lightblue" width="50"><xsl:value-of select="$i18n/l/Replies"/></td>
                            <td class="lightblue" width="134"><xsl:value-of select="$i18n/l/Last_reply"/></td>
                        </tr>
                        <xsl:apply-templates select="children/object">
                            <xsl:sort select="title" order="descending"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
            </xsl:choose>
        </xsl:when>
--><!-- end sort by name --><!--
--><!-- begin sort by date --><!--
        <xsl:when test="$sb='date' or $sb='position'">
            <xsl:choose>
--><!-- begin sort by date asc --><!--
                <xsl:when test="$order='asc'">
                <table class="10left" border="0" cellpadding="3" cellspacing="0" width="800">
                    <tr>
                        <td class="lightblue">
                            <a href="?sb=name">
                                <xsl:value-of select="$i18n/l/Topic"/>
                            </a>
                        </td>
                        <td class="lightblue" width="120" nowrap="nowrap">
                            <a href="?sb=date&amp;order=desc">
                                <xsl:value-of select="$i18n/l/Created"/>
                                <img src="{$skimages}arrow_ascending.gif" width="10" height="10" border="0" alt="sort descending"/>
                            </a>
                        </td>
                        <td class="lightblue" width="134"><xsl:value-of select="$i18n/l/Author"/></td>
                        <td class="lightblue" width="50"><xsl:value-of select="$i18n/l/Replies"/></td>
                        <td class="lightblue" width="134"><xsl:value-of select="$i18n/l/Last_reply"/></td>
                    </tr>
                    <xsl:apply-templates select="children/object">
                        <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="ascending"/>
                    </xsl:apply-templates>
                </table>
                </xsl:when>
--><!-- end sort by date asc--><!--
--><!-- begin sort by date desc --><!--
                <xsl:when test="$order='desc'">
                <table class="10left" border="0" cellpadding="3" cellspacing="0" width="800">
                    <tr>
                        <td class="lightblue">
                            <a href="?sb=name">
                                <xsl:value-of select="$i18n/l/Topic"/>
                            </a>
                        </td>
                        <td class="lightblue" width="120">
                            <a href="?sb=date&amp;order=asc">
                                <xsl:value-of select="$i18n/l/Created"/>
                                <img src="{$skimages}arrow_descending.gif" width="10" height="10" border="0" alt="sort ascending"/>
                            </a>
                        </td>
                        <td class="lightblue" width="134"><xsl:value-of select="$i18n/l/Author"/></td>
                        <td class="lightblue" width="50"><xsl:value-of select="$i18n/l/Replies"/></td>
                        <td class="lightblue" width="134"><xsl:value-of select="$i18n/l/Last_reply"/></td>
                    </tr>
                    <xsl:apply-templates select="children/object">
                        <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="descending"/>
                    </xsl:apply-templates>
                </table>
                </xsl:when>
--><!-- end sort by desc --><!--
            </xsl:choose>
        </xsl:when>
--><!-- end sort by date --><!--
    </xsl:choose>
</xsl:template>-->

<xsl:template match="children/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>

    <tr height="25">
        <xsl:choose>
<!-- begin sort by name -->
            <xsl:when test="$sb='name'">
                <td bgcolor="#eeeeee" valign="bottom">
                    <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
                    <xsl:text> </xsl:text>
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
                        <xsl:value-of select="title" />
                    </a>
                </td>
                <td nowrap="nowrap" valign="middle" align="center">
                    <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                </td>
            </xsl:when>
<!-- end sort by name -->
<!-- begin sort by date -->
            <xsl:when test="$sb='date' or $sb='position'">
                <td valign="middle">
                    <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
                    <xsl:text> </xsl:text>
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
                    <xsl:value-of select="title" /></a>
                </td>
                <td nowrap="nowrap" bgcolor="#eeeeee" valign="middle" align="center">
                    <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                </td>
            </xsl:when>
<!-- end sort by date -->
        </xsl:choose>
        <td align="left" valign="middle">
            <a>
                <xsl:attribute name="href">mailto:<xsl:value-of select="attributes/email"/>?subject=RE: <xsl:value-of select="title"/></xsl:attribute>
                <xsl:value-of select="attributes/author"/>
            </a>
            <xsl:choose>
                <xsl:when test="attributes/coemail">,
                    <a>
                        <xsl:attribute name="href">mailto:<xsl:value-of select="attributes/coemail"/>?subject=RE: <xsl:value-of select="title"/></xsl:attribute>
                        <xsl:value-of select="attributes/coauthor"/>
                    </a>
                </xsl:when>
                <xsl:when test="attributes/coauthor">,<br/> <xsl:value-of select="attributes/coauthor"/>
                </xsl:when>
            </xsl:choose>
        </td>
        <td valign="middle" align="center">
            <xsl:value-of select="descendant_count"/>
        </td>
        <td nowrap="nowrap" valign="middle" align="center">
            <xsl:if test="descendant_count != '0'">
                <xsl:apply-templates select="descendant_last_modification_timestamp" mode="datetime"/>
            </xsl:if>
        </td>
        <td valign="bottom">
        <xsl:if test="user_privileges/delete">
            <form style="margin:0px;" name="delete" method="get" action="{$xims_box}{$goxims_content}">
                <input type="hidden" name="delete_prompt" value="1"/>
                <input type="hidden" name="id" value="{@id}"/>
                <input type="image" src="{$skimages}option_delete.png" border="0" width="37" height="19" title="delete" alt="delete"/>
            </form>
        </xsl:if>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
