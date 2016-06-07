<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: departmentroot_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:template match="objectlist/object">
    <div class="tr-deptportlets-item">
      <div class="deptportlets-item">
        <a href="{$goxims_content}{location_path}"><xsl:value-of select="title"/></a>
      </div>
      <a href="{$goxims_content}{$absolute_path}?portlet_id={id}&amp;rem_portlet=1">
	      <img src="{$skimages}option_delete.png"
	            border="0"
	            width="37"
	            height="19"
	            alt="{$i18n/l/delete}"
	            title="{$i18n/l/delete}"
	      />
      </a>
    </div>
</xsl:template>

<!-- UIBK special -->
<xsl:template name="select-faculty">
    <div>
        <select name="faculty">
          <option value="">Fakultät auswählen</option>
          <option value="architektur">
            <xsl:if test="attributes/faculty = 'architektur'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Architektur</xsl:text>
          </option>
          <option value="baufakultaet">
            <xsl:if test="attributes/faculty = 'baufakultaet'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Bauingenieurwissenschaften</xsl:text>
          </option>
          <option value="bwl">
            <xsl:if test="attributes/faculty = 'bwl'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Betriebswirtschaft</xsl:text>
          </option>
          <option value="biwi">
            <xsl:if test="attributes/faculty = 'biwi'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Bildungswissenschaften</xsl:text>
          </option>
          <option value="biologie">
            <xsl:if test="attributes/faculty = 'biologie'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Biologie</xsl:text>
          </option>
          <option value="chemie-pharmazie">
            <xsl:if test="attributes/faculty = 'chemie-pharmazie'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Chemie und Pharmazie</xsl:text>
          </option>
          <option value="geo-atmosphaeren">
            <xsl:if test="attributes/faculty = 'geo-atmosphaeren'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Geo- und AtmosphÃ¤renwissenschaften</xsl:text>
          </option>
          <option value="mip">
            <xsl:if test="attributes/faculty = 'mip'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Mathematik, Informatik und Physik</xsl:text>
          </option>
          <option value="pol-soz">
            <xsl:if test="attributes/faculty = 'pol-soz'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Politikwissenschaft und Soziologie</xsl:text>
          </option>
          <option value="psychologie-sport">
            <xsl:if test="attributes/faculty = 'psychologie-sport'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Psychologie und Sportwissenschaft</xsl:text>
          </option>
          <option value="vwl">
            <xsl:if test="attributes/faculty = 'vwl'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Fakultät für Volkswirtschaft und Statistik</xsl:text>
          </option>
          <option value="theologie">
            <xsl:if test="attributes/faculty = 'theologie'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Katholisch-Theologische Fakultät</xsl:text>
          </option>
          <option value="phil-kult">
            <xsl:if test="attributes/faculty = 'phil-kult'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Philologisch-Kulturwissenschaftliche Fakultät</xsl:text>
          </option>
          <option value="phil-hist">
            <xsl:if test="attributes/faculty = 'phil-hist'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Philosophisch-Historische Fakultät</xsl:text>
          </option>
          <option value="rewi">
            <xsl:if test="attributes/faculty = 'rewi'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Rechtswissenschaftliche Fakultät</xsl:text>
          </option>
          <option value="soe">
            <xsl:if test="attributes/faculty = 'soe'">
              <xsl:attribute name="selected">
                <xsl:text>selected</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>School of Education</xsl:text>
          </option>
        </select>
    </div>
  </xsl:template>
  
  <xsl:template name="select_category">
    <div>
        <p>
            Kategorie auswählen: (Zuordnung im Farbleitsystem) <br/>
            <xsl:value-of select="$i18n/l/Select_category"/>
            <input name="category" type="radio" value="none">
                <xsl:if test="not(attributes/category)">
                    <xsl:attribute name="checked"><xsl:text>checked</xsl:text></xsl:attribute>
                </xsl:if>                
            </input>Fakultäten (Standard)<br/>
            <input name="category" type="radio" value="universitaet">
                <xsl:if test="attributes/category = 'universitaet'">
                    <xsl:attribute name="checked"><xsl:text>checked</xsl:text></xsl:attribute>
                </xsl:if>                
            </input>Universität<br/>
            <input name="category" type="radio" value="forschung">
                <xsl:if test="attributes/category = 'forschung'">
                    <xsl:attribute name="checked"><xsl:text>checked</xsl:text></xsl:attribute>
                </xsl:if>                
            </input>Forschung<br/>
            <input name="category" type="radio" value="studium">
                <xsl:if test="attributes/category = 'studium'">
                    <xsl:attribute name="checked"><xsl:text>checked</xsl:text></xsl:attribute>
                </xsl:if>                
            </input>Studium<br/>
            <input name="category" type="radio" value="internationales">
                <xsl:if test="attributes/category = 'internationales'">
                    <xsl:attribute name="checked"><xsl:text>checked</xsl:text></xsl:attribute>
                </xsl:if>                
            </input>Internationales<br/>
            <input name="category" type="radio" value="portal">
                <xsl:if test="attributes/category = 'portal'">
                    <xsl:attribute name="checked"><xsl:text>checked</xsl:text></xsl:attribute>
                </xsl:if>                
            </input>Portal (Grau)<br/>
            <input name="category" type="radio" value="ipoint">
                <xsl:if test="attributes/category = 'ipoint'">
                    <xsl:attribute name="checked"><xsl:text>checked</xsl:text></xsl:attribute>
                </xsl:if>
            </input>iPoint
        </p>
    </div>
</xsl:template>
<!-- end UIBK special -->

</xsl:stylesheet>
