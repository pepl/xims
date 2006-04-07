<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:od="urn:schemas-microsoft-com:officedata">

    <xsl:variable name="chartable"
        select="document('simpledb_access_xmlimport_chartable.xml')/chartable"/>
    <xsl:variable name="tablename" select="'SimpleDB'"/>

    <xsl:template match="/document/context/object">
        <xsl:variable name="now">
            <xsl:apply-templates select="/document/context/session/date" mode="ISO8601"/>
        </xsl:variable>
        <root>
            <xsd:schema>
                <xsd:element name="dataroot">
                    <xsd:complexType>
                        <xsd:sequence>
                            <xsd:element ref="{$tablename}" minOccurs="0" maxOccurs="unbounded"/>
                        </xsd:sequence>
                        <xsd:attribute name="generated" type="xsd:dateTime"/>
                    </xsd:complexType>
                </xsd:element>
                <xsd:element name="{$tablename}">
                    <xsd:annotation>
                        <xsd:appinfo>
                            <od:index index-name="PrimaryKey" index-key="ID " primary="yes" unique="yes" clustered="no"/>
                            <od:index index-name="ID" index-key="ID " primary="no" unique="no" clustered="no"/>
                        </xsd:appinfo>
                    </xsd:annotation>
                    <xsd:complexType>
                        <xsd:sequence>
                            <xsd:element name="ID" minOccurs="1" od:jetType="autonumber" od:sqlSType="int" od:autoUnique="yes" od:nonNullable="yes" type="xsd:int"/>
                            <xsl:apply-templates
                                select="/document/member_properties/member_property"/>
                        </xsd:sequence>
                    </xsd:complexType>
                </xsd:element>
            </xsd:schema>
            <dataroot xmlns:od="urn:schemas-microsoft-com:officedata" generated="{$now}">
                <xsl:apply-templates select="children/object">
                    <xsl:sort select="title" order="ascending"/>
                </xsl:apply-templates>
            </dataroot>
        </root>
    </xsl:template>

    <xsl:template match="object">
        <xsl:variable name="escaped_tablename">
            <xsl:call-template name="string-escape">
                <xsl:with-param name="string">
                    <xsl:value-of select="$tablename"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="id" select="@id"/>

        <xsl:element name="{$escaped_tablename}">
            <ID><xsl:value-of select="@id"/></ID>
            <xsl:apply-templates select="member_values/member_value">
                <xsl:sort
                    select="/document/member_properties/member_property[@id = current()/property_id]/position"
                    order="ascending" data-type="number"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="member_value">
        <xsl:variable name="property_id" select="property_id"/>
        <xsl:variable name="property_type" select="/document/member_properties/member_property[@id=$property_id]/type"/>
        <xsl:variable name="escaped_propertyname">
            <xsl:call-template name="string-escape">
                <xsl:with-param name="string">
                    <xsl:value-of
                        select="/document/member_properties/member_property[@id=$property_id]/name"
                    />
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:element name="{$escaped_propertyname}">
            <xsl:choose>
                <xsl:when test="$property_type='datetime'"><xsl:value-of select="concat(translate(value,' ','T'),':00')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="value"/></xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="member_property">
        <xsl:variable name="escaped_propertyname">
            <xsl:call-template name="string-escape">
                <xsl:with-param name="string">
                    <xsl:value-of
                        select="name"
                    />
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsd:element name="{$escaped_propertyname}" minOccurs="0" od:jetType="text" od:sqlSType="nvarchar">
            <xsd:simpleType>
                <xsd:restriction base="xsd:string">
                    <xsd:maxLength value="255"/>
                </xsd:restriction>
            </xsd:simpleType>
        </xsd:element>
    </xsl:template>

    <xsl:template match="member_property[type='datetime']">
        <xsl:variable name="escaped_propertyname">
            <xsl:call-template name="string-escape">
                <xsl:with-param name="string">
                    <xsl:value-of
                        select="name"
                    />
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsd:element name="{$escaped_propertyname}" minOccurs="0" od:jetType="datetime" od:sqlSType="datetime" type="xsd:dateTime"/>
    </xsl:template>

<!-- MS Access 2003 does not re-import Boolean data types correctly...Import those as string for now
    <xsl:template match="member_property[type='boolean']">
        <xsl:variable name="escaped_propertyname">
            <xsl:call-template name="string-escape">
                <xsl:with-param name="string">
                    <xsl:value-of
                        select="name"
                    />
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsd:element name="{$escaped_propertyname}" minOccurs="1" od:jetType="yesno" od:sqlSType="bit" od:nonNullable="yes" type="xsd:boolean"/>
    </xsl:template>
-->

    <xsl:template match="member_property[type='integer']">
        <xsl:variable name="escaped_propertyname">
            <xsl:call-template name="string-escape">
                <xsl:with-param name="string">
                    <xsl:value-of
                        select="name"
                    />
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsd:element name="{$escaped_propertyname}" minOccurs="1" od:jetType="longinteger" od:sqlSType="int" type="xsd:int"/>
    </xsl:template>

    <xsl:template match="member_property[type='textarea']">
        <xsl:variable name="escaped_propertyname">
            <xsl:call-template name="string-escape">
                <xsl:with-param name="string">
                    <xsl:value-of
                        select="name"
                    />
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsd:element name="{$escaped_propertyname}" minOccurs="0" od:jetType="memo" od:sqlSType="ntext">
            <xsd:simpleType>
                <xsd:restriction base="xsd:string">
                    <xsd:maxLength value="2000"/>
                </xsd:restriction>
            </xsd:simpleType>
        </xsd:element>
    </xsl:template>
  
    <xsl:template name="string-escape">
        <xsl:param name="string"/>
        <xsl:variable name="len" select="string-length($string)"/>

        <xsl:if test="$len &gt; 0">
            <xsl:variable name="chr" select="substring($string, 1, 1)"/>
            <xsl:variable name="rep" select="string($chartable/char[@val = $chr]/@rep)"/>
            <xsl:choose>
                <xsl:when test="string($rep) = ''">
                    <xsl:value-of select="$chr"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$rep"/>
                </xsl:otherwise>
            </xsl:choose>

            <!-- Divide and Conquer to avoid Stack Overflow -->
            <xsl:call-template name="string-escape">
                <xsl:with-param name="string" select="substring($string, 2, $len div 2)"/>
            </xsl:call-template>

            <xsl:call-template name="string-escape">
                <xsl:with-param name="string"
                    select="substring($string, 2 + $len div 2, $len div 2)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
