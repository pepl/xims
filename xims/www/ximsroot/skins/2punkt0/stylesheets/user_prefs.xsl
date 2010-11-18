<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
                
<xsl:import href="common.xsl"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/session/user"/>
</xsl:template>

<xsl:template match="/document/context/session/user">
    <html>
        <xsl:call-template name="head_default">
					<xsl:with-param name="mode">user</xsl:with-param>
        </xsl:call-template>
        <body>
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>
            <div id="content-container">

            <h1 class="bluebg">
            <xsl:value-of select="$i18n/l/ManagePersonalSettings"/>!
            </h1>
            <form name="userEdit" action="{$xims_box}{$goxims}/userprefs" method="post" id="create-edit-form">
            
            <strong><xsl:value-of select="$i18n/l/SelectSkin"/></strong><br/>
            <input type="radio" id="skin_def" class="radio-button" name="skin" value="default">
            <xsl:if test="userprefs/userprefs/skin = 'default'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
            </input> <label for="skin_def">default</label> <br/>
						<input type="radio" id="skin_2p0" class="radio-button" name="skin" value="2punkt0">
						<xsl:if test="userprefs/userprefs/skin = '2punkt0'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
						</input> <label for="skin_2p0">2punkt0</label> <br/>
            
            <br/> 
            
            <strong><xsl:value-of select="$i18n/l/Publish"/></strong><br/>
							<label for="publish_at_save"><xsl:value-of select="$i18n/l/Pub_on_save"/></label> 
							<input type="checkbox" name="publish_at_save" id="publish_at_save" class="checkbox"><xsl:if test="userprefs/userprefs/publish_at_save = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input>
							<br />
							<br/> 
						
            <strong><xsl:value-of select="$i18n/l/Container_View"/></strong><br/>
							<xsl:value-of select="$i18n/l/whatToShow"/>? <br />
							<input type="radio" id="conview_title" class="radio-button" name="containerview_show" value="title"><xsl:if test="userprefs/userprefs/containerview_show = 'title'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <label for="conview_title"><xsl:value-of select="$i18n/l/Title"/></label> <br/>
						<input type="radio" id="conview_loc" class="radio-button" name="containerview_show" value="location"><xsl:if test="userprefs/userprefs/containerview_show = 'location'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <label for="conview_loc"><xsl:value-of select="$i18n/l/Location"/></label> <br/>
							<br />
							 <br/><br/>
									 <input type="hidden" name="id"><xsl:attribute name="value"><xsl:value-of select="userprefs/userprefs/id"/></xsl:attribute></input>
									 <input type="hidden" name="profile_type"><xsl:attribute name="value"><xsl:value-of select="userprefs/userprefs/profile_type"/></xsl:attribute></input>
                        <button name="create" type="submit">
							<xsl:value-of select="$i18n/l/save"/>                     
                        </button>
													&#160;
                        <!--<button name="cancel" type="button" onclick="javascript:history.go(-1)">
							<xsl:value-of select="$i18n/l/cancel"/></button>-->
						</form>
							<br/>
							<p class="back">
                    <a href="{$xims_box}{$goxims}/user"><xsl:value-of select="$i18n/l/BackToHome"/></a>
                </p>
            </div>
            <xsl:call-template name="script_bottom" />
            </body>
            </html>
  </xsl:template>    
            
</xsl:stylesheet>