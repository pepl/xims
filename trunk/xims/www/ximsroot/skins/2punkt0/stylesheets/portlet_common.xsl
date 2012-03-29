<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: portlet_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="common.xsl"/>
	<xsl:import href="link_common.xsl"/>
	
	<xsl:variable name="i18n_portlet" select="document(concat($currentuilanguage,'/i18n_portlet.xml'))"/>
	<!-- think of an object-type property "independent" instead of filtering object_types by name -->
	<xsl:variable name="filtered_ots">
		<!--<xsl:for-each select="/document/object_types/object_type[name != 'Portlet' and name != 'Portal' and name != 'Annotation' and name != 'VLibraryItem' and name != 'DocBookXML']">-->
		<xsl:for-each select="/document/object_types/object_type[name != 'Portlet' and name != 'Portal' and name != 'Annotation' and name != 'DocBookXML']">
			<xsl:sort select="translate(fullname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending" data-type="text"/>
			<xsl:copy>
				<xsl:copy-of select="@*|*"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:template name="extra_properties">
	<!--<div class="form-div block">
	<h2>Extra Properties</h2>-->
		<p>
			<xsl:value-of select="$i18n_portlet/l/Extra_Properties"/>
		</p>
		<div class="div-row">
			<div id="tr-created_by_fullname">
				<div class="label-extraprop">
					<label for="ep_created_by_fullname">
						<xsl:value-of select="$i18n_portlet/l/Creator"/>
					</label>
				</div>
				<input type="checkbox" name="col_created_by_fullname" id="ep_created_by_fullname" class="checkbox">
					<xsl:if test="body/content/column[@name = 'created_by_firstname']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-owned_by_fullname">
				<div class="label-extraprop">
					<label for="ep_owned_by_fullname">
						<xsl:value-of select="$i18n_portlet/l/Owner"/>
					</label>
				</div>
				<input type="checkbox" name="col_owned_by_fullname" class="checkbox" id="ep_owned_by_fullname">
					<xsl:if test="body/content/column[@name = 'owned_by_firstname']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-last_modified_by_fullname">
				<div class="label-extraprop">
					<label for="ep_last_modified_by_fullname">
						<xsl:value-of select="$i18n_portlet/l/Last_modifier"/>
					</label>
				</div>
				<input type="checkbox" name="col_last_modified_by_fullname" id="ep_last_modified_by_fullname" class="checkbox">
					<xsl:if test="body/content/column[@name = 'last_modified_by_firstname']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
		</div>
		<div class="div-row">
			<div id="tr-creation_timestamp">
				<div class="label-extraprop">
					<label for="creation_timestamp">
						<xsl:value-of select="$i18n_portlet/l/Creation_timestamp"/>
					</label>
				</div>
				<input type="checkbox" name="col_creation_timestamp" id="creation_timestamp" class="checkbox">
					<xsl:if test="body/content/column[@name = 'creation_timestamp']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-last_publication_timestamp">
				<div class="label-extraprop">
					<label for="last_publication_timestamp">
						<xsl:value-of select="$i18n_portlet/l/Publication_timestamp"/>
					</label>
				</div>
				<input type="checkbox" name="last_publication_timestamp" id="last_publication_timestamp" class="checkbox">
					<xsl:if test="body/content/column[@name = 'last_publication_timestamp']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-last_modification_timestamp">
				<div class="label-extraprop">
					<label for="last_modification_timestamp">
						<xsl:value-of select="$i18n_portlet/l/Last_modification_timestamp"/>
					</label>
				</div>
				<input type="checkbox" name="last_modification_timestamp" id="last_modification_timestamp" class="checkbox">
					<xsl:if test="body/content/column[@name = 'last_modification_timestamp']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
		</div>
		<div class="div-row">
			<div id="tr-valid_from_timestamp">
				<div class="label-extraprop">
					<label for="valid_from_timestamp">
						<xsl:value-of select="$i18n_portlet/l/Valid_from_timestamp"/>
					</label>
				</div>
				<input type="checkbox" name="valid_from_timestamp" id="valid_from_timestamp" class="checkbox">
					<xsl:if test="body/content/column[@name = 'valid_from_timestamp']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-valid_to_timestamp">
				<div class="label-extraprop">
					<label for="valid_to_timestamp">
						<xsl:value-of select="$i18n_portlet/l/Valid_to_timestamp"/>
					</label>
				</div>
				<input type="checkbox" name="valid_to_timestamp" id="valid_to_timestamp" class="checkbox">
					<xsl:if test="body/content/column[@name = 'valid_to_timestamp']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
		</div>
		<div class="div-row">
			<div id="tr-col_abstract">
				<div class="label-extraprop">
					<label for="ep_abstract">
						<xsl:value-of select="$i18n/l/Abstract"/>
					</label>
				</div>
				<input type="checkbox" name="col_abstract" id="ep_abstract" class="checkbox">
					<xsl:if test="body/content/column[@name = 'abstract']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-marked_new">
				<div class="label-extraprop">
					<label for="ep_marked_new">
						<xsl:value-of select="$i18n_portlet/l/Marked_new"/>
					</label>
				</div>
				<input type="checkbox" name="col_marked_new" id="ep_marked_new" class="checkbox">
					<xsl:if test="body/content/column[@name = 'marked_new']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-status">
				<div class="label-extraprop">
					<label for="ep_status">
						<xsl:value-of select="$i18n/l/Status"/>
					</label>
				</div>
				<input type="checkbox" name="col_status" id="ep_status" class="checkbox">
					<xsl:if test="body/content/column[@name = 'status']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
		</div>
		<div class="div-row">
			<div id="tr-attributes">
				<div class="label-extraprop">
					<label for="ep_attributes">
						<xsl:value-of select="$i18n_portlet/l/Attributes"/>
					</label>
				</div>
				<input type="checkbox" name="col_attributes" id="ep_attributes" class="checkbox">
					<xsl:if test="body/content/column[@name = 'attributes']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-col_image_id">
				<div class="label-extraprop">
					<label for="ep_image_id">
						<xsl:value-of select="$i18n/l/Image"/>
					</label>
				</div>
				<input type="checkbox" name="col_image_id" id="ep_image_id" class="checkbox">
					<xsl:if test="body/content/column[@name = 'image_id']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-ep_body">
				<div class="label-extraprop">
					<label for="ep_body">
					 <xsl:value-of select="$i18n/l/Body"/>
					</label>
				</div>
				<input type="checkbox" name="col_body" id="ep_body" class="checkbox">
					<xsl:if test="body/content/column[@name = 'body']">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
		</div>
<br clear="all"/>		
		<!--</div>-->
	</xsl:template>
	
	<xsl:template name="tree_depth">
		<div id="tr-depth">
			<div class="label">
				<label for="select-depth">
					<xsl:value-of select="$i18n_portlet/l/How_deep"/>
				</label>
			</div>
			<select name="depth" id="select-depth" class="select">
				<option value="1">
					<xsl:attribute name="selected"><xsl:text>selected</xsl:text></xsl:attribute>1</option>
				<option value="2">
					<xsl:if test="body/content[depth =2]">
						<xsl:attribute name="selected">selected</xsl:attribute>
					</xsl:if>2</option>
				<option value="3">
					<xsl:if test="body/content[depth =3]">
						<xsl:attribute name="selected">selected</xsl:attribute>
					</xsl:if>3</option>
				<option value="4">
					<xsl:if test="body/content[depth =4]">
						<xsl:attribute name="selected">selected</xsl:attribute>
					</xsl:if>4</option>
				<option value="5">
					<xsl:if test="body/content[depth =5]">
						<xsl:attribute name="selected">selected</xsl:attribute>
					</xsl:if>5</option>
			</select>
			<xsl:text> Levels</xsl:text>
			<!--              <input name="f_depth" type="radio" value="true" id="radio-f_depth-true" class="radio-button">
                  <xsl:if test="body/content/depth != ''">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                  </xsl:if>
                </input>
              <label for="radio-f_depth-true"><xsl:value-of select="$i18n/l/Yes"/></label>
              
                <input name="f_depth" type="radio" value="false" id="radio-f_depth-false" class="radio-button">
                  <xsl:if test="not(body/content/depth) or body/content/depth = ''">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                  </xsl:if>
                  </input>
                <label for="radio-f_depth-false"><xsl:value-of select="$i18n/l/No"/></label>-->
		</div>
	</xsl:template>
	
	<xsl:template name="add_documentlinks">
		<div id="tr-add-doclinks">
			<div class="label">
				<label for="input-add-doclinks">
					<xsl:value-of select="$i18n_portlet/l/Add_documentlinks"/>
				</label>
			</div>
			<input type="checkbox" name="documentlinks" id="input-add-doclinks" class="checkbox">
				<xsl:if test="body/content[documentlinks=1]">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
		</div>
	</xsl:template>
	
	<xsl:template name="filter_latest">
	<div id="tr-filter-latest">
		<div class="label-large">
			<label for="input-filter-latest">
				<xsl:value-of select="$i18n_portlet/l/Filter_latest"/>:
				</label>
				</div>
            <select name="latest" class="select" id="input-filter-latest">
					<option value="1">
						<xsl:if test="body/content[latest =1]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>1</option>
					<option value="2">
						<xsl:if test="body/content[latest =2]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>2</option>
					<option value="3">
						<xsl:if test="body/content[latest =3]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>3</option>
					<option value="4">
						<xsl:if test="body/content[latest =4]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>4</option>
					<option value="5">
						<xsl:if test="body/content[latest =5]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>5</option>
					<option value="6">
						<xsl:if test="body/content[latest =6]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>6</option>
					<option value="7">
						<xsl:if test="body/content[latest =7]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>7</option>
					<option value="8">
						<xsl:if test="body/content[latest =8]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>8</option>
					<option value="9">
						<xsl:if test="body/content[latest =9]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>9</option>
					<option value="10">
						<xsl:if test="body/content[latest =10]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>10</option>
					<option value="15">
						<xsl:if test="body/content[latest =15]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>15</option>
					<option value="20">
						<xsl:if test="body/content[latest =20]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>20</option>
					<option value="25">
						<xsl:if test="body/content[latest =25]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>25</option>
					<option value="30">
						<xsl:if test="body/content[latest =30]">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>30</option>
				</select>
		
				<input name="f_latest" type="radio" value="true" class="radio-button" id="f_latest-true">
					<xsl:if test="body/content/latest != ''">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="f_latest-true"><xsl:value-of select="$i18n/l/Yes"/></label>
				<input name="f_latest" type="radio" value="false" class="radio-button" id="f_latest-false">
					<xsl:if test="not(body/content/latest) or body/content/latest = ''">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="f_latest-false"><xsl:value-of select="$i18n/l/No"/></label>
			</div>
		
		<div id="tr-filter-latest-sortkey">
			<div class="label-large">
			<label for="input-filter-latest-sortkey">
				<xsl:value-of select="$i18n_portlet/l/Filter_latest_sortkey"/>:
				</label>
				</div>
            <select name="f_latest_sortkey" id="input-filter-latest-sortkey" class="select">
								<option value="last_modification_timestamp">
									<xsl:value-of select="$i18n_portlet/l/Last_modification_timestamp"/>
								</option>
								<option value="valid_from_timestamp">
									<xsl:if test="body/content/latest_sortkey != '' and body/content/latest_sortkey = 'valid_from_timestamp'">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="$i18n_portlet/l/Valid_from_timestamp"/>
								</option>
						</select>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('filter_latest_sortkey')" class="doclink">(?)</a>
			</div>
	</xsl:template>
	
	<xsl:template name="contentfilters">
	
		<div class="form-div block">
		<h2><xsl:value-of select="$i18n/l/FilterCriteria"/></h2>
			<xsl:call-template name="extra_properties"/>
			<xsl:call-template name="filter_latest"/>
			
			<div id="tr-filter-markednew">
				<div class="label-large"><label for="input-filter-markednew"><xsl:value-of select="$i18n_portlet/l/Filter_marked_new"/>:</label></div>
				<input type="checkbox" name="filternews" id="input-filter-markednew" class="checkbox">
					<xsl:if test="body/filter[marked_new=1]">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
			</div>
			<div id="tr-filter-published">
				<div class="label-large"><label for="input-filter-published"><xsl:value-of select="$i18n_portlet/l/Filter_published"/>:</label></div>
				<input type="checkbox" name="filterpublished" id="input-filter-published" class="checkbox">
					<xsl:if test="body/filter[published=1]">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<br/>
			</div>
		
<!--		 reactivate after Portlet stuff is refactored and cleaned-up
        <td>
            <textarea name="extra_filters" rows="30" cols="45">
                <xsl:choose>
                    <xsl:when test="body/filter/*[not(name() = 'new') and not(name() = 'published')]">
                        <xsl:apply-templates select="body/filter/*[not(name() = 'new') and not(name() = 'published')]" mode="filter"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </textarea>
        </td>-->
        
		<p><xsl:value-of select="$i18n_portlet/l/Filter_object_types"/>:</p>
		<div class="div-row">
			<xsl:apply-templates select="exslt:node-set($filtered_ots)/object_type[can_create]" mode="contentfilter"/>
		</div>
		&#160;<br/>
		<!-- Nodes outside the node-set cannot be checked, therefore we have to check the filtered object-types via JavaScript -->
		<xsl:apply-templates select="body/content/object-type" mode="contentfilter"/>
		            &#160;<br/>
     </div>
		<xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
				var inputs = document.getElementsByTagName("input");
    var re = new RegExp("filter_ot_");
    var el;
    for (var i = inputs.length - 1; i &gt; 0; --i ) {
    	re.test(inputs[i].name);
        if (RegExp.rightContext.length &gt; 0) {
        	el = document.getElementById("ot_" + RegExp.rightContext)
            if ( el )
            	//el.checked = 1;
            	el.checked = 'checked';
         }
	}
			</xsl:with-param>
		</xsl:call-template>
<!--		<script type="text/javascript">
				//object_type_filter();
				
            </script>-->
	</xsl:template>

	<xsl:template match="object_type" mode="contentfilter">
		<div>
			<div>
				<label for="ot_{fullname}">
					
					<xsl:if test="parent_id != ''">
						<xsl:variable name="parent_id" select="parent_id"/>
						<xsl:call-template name="objtype_name">
							<xsl:with-param name="ot_name">
								<xsl:value-of select="exslt:node-set($filtered_ots)/object_type[@id=$parent_id]/name"/>
							</xsl:with-param>
						</xsl:call-template><xsl:text>::</xsl:text>
					</xsl:if>
					<xsl:call-template name="objtype_name">
					<xsl:with-param name="ot_name">
						<xsl:value-of select="name"/>
					</xsl:with-param>
					</xsl:call-template>
					
				</label>
			</div>
			<input type="checkbox" name="ot_{fullname}" id="ot_{fullname}" class="checkbox"/>
		</div>
	</xsl:template>
	
	<xsl:template match="object-type" mode="contentfilter">
		<input type="hidden" name="filter_ot_{@name}"/>
	</xsl:template>
	
	<xsl:template match="*" mode="filter">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="filter"/>
		</xsl:copy>
	</xsl:template>

<xsl:template name="form-keywords"/>

<xsl:template name="form-obj-specific">
		<div class="form-div block">
		<h2><xsl:value-of select="$i18n/l/ExtraOptions"/></h2>
			<xsl:call-template name="tree_depth"/>
			<xsl:call-template name="add_documentlinks"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
