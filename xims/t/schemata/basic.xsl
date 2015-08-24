<?xml version="1.0" standalone="yes"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://www.ascc.net/xml/schematron" version="1.0">
  <axsl:template match="*|@*" mode="schematron-get-full-path">
    <axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
    <axsl:text>/</axsl:text>
    <axsl:if test="count(. | ../@*) = count(../@*)">@</axsl:if>
    <axsl:value-of select="name()"/>
    <axsl:text>[</axsl:text>
    <axsl:value-of select="1+count(preceding-sibling::*[name()=name(current())])"/>
    <axsl:text>]</axsl:text>
  </axsl:template>
  <axsl:template match="/">
    <axsl:apply-templates xmlns:sch="http://www.ascc.net/xml/schematron" select="/" mode="M0"/>
  </axsl:template>
  <axsl:template match="/*" priority="4000" mode="M0">
    <axsl:choose>
      <axsl:when test="name()='document'"/>
      <axsl:otherwise>The top level element must be named 'document'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="document" priority="3999" mode="M0">
    <axsl:choose>
      <axsl:when test="count(session)=1"/>
      <axsl:otherwise>The 'document' element must be contain a 'session' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(session|context|objectlist|userlist|language|object-types|data-formats)=count(../*)"/>
      <axsl:otherwise>Foreign element child<axsl:text xml:space="preserve"> </axsl:text><axsl:value-of select="name(.)"/><axsl:text xml:space="preserve"> </axsl:text>in element 'document'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="session" priority="3998" mode="M0">
    <axsl:choose>
      <axsl:when test="count(last_access_timestamp)=1"/>
      <axsl:otherwise>The 'session' element must be contain a 'last_access_timestamp' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(host)=1"/>
      <axsl:otherwise>The 'session' element must be contain a 'host' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(user)=1"/>
      <axsl:otherwise>The 'session' element must be contain a 'user' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(date)=1"/>
      <axsl:otherwise>The 'session' element must be contain a 'date' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(last_access_timestamp|host|user|user_id|date|error_msg|warning_msg|message|verbose_msg|skin|uilanguage|session_id|attributes|serverurl)=count(./*)"/>
      <axsl:otherwise>Foreign element child<axsl:text xml:space="preserve"> </axsl:text><axsl:value-of select="name(.)"/><axsl:text xml:space="preserve"> </axsl:text>in element 'session'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="context" priority="3997" mode="M0">
    <axsl:choose>
      <axsl:when test="count(user|object)=count(*)"/>
      <axsl:otherwise>Foreign element child<axsl:text xml:space="preserve"> </axsl:text><axsl:value-of select="name(.)"/><axsl:text xml:space="preserve"> </axsl:text>in element 'context'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="objectlist" priority="3996" mode="M0">
    <axsl:choose>
      <axsl:when test="count(object) &gt; 0"/>
      <axsl:otherwise>Element 'objectlist' must contain at least one 'object' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(object)=count(*)"/>
      <axsl:otherwise>Foreign element child<axsl:text xml:space="preserve"> </axsl:text><axsl:value-of select="name(.)"/><axsl:text xml:space="preserve"> </axsl:text>in element 'objectlist'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="userlist" priority="3995" mode="M0">
    <axsl:choose>
      <axsl:when test="count(user) &gt; 0"/>
      <axsl:otherwise>Element 'userlist' must contain at least one 'user' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(user)=count(*)"/>
      <axsl:otherwise>Foreign element child<axsl:text xml:space="preserve"> </axsl:text><axsl:value-of select="name(.)"/><axsl:text xml:space="preserve"> </axsl:text>in element 'userlist'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="language" priority="3994" mode="M0">
    <axsl:choose>
      <axsl:when test="count(fullname)=1"/>
      <axsl:otherwise>The 'language' element must be contain one 'fullname' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(code)=1"/>
      <axsl:otherwise>The 'language' element must be contain one 'code' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(fullname|code)=count(*)"/>
      <axsl:otherwise>Foreign element child<axsl:text xml:space="preserve"> </axsl:text><axsl:value-of select="name(.)"/><axsl:text xml:space="preserve"> </axsl:text>in element 'language'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="object-types" priority="3993" mode="M0">
    <axsl:choose>
      <axsl:when test="count(object-type)=count(*)"/>
      <axsl:otherwise>Foreign element child<axsl:text xml:space="preserve"> </axsl:text><axsl:value-of select="name(.)"/><axsl:text xml:space="preserve"> </axsl:text>in element 'object-types'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="object[name(..) != 'context']" priority="3992" mode="M0">
    <axsl:choose>
      <axsl:when test="@id"/>
      <axsl:otherwise>Element 'object' must contain an 'id' attribute.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="@document_id"/>
      <axsl:otherwise>Element 'object' must contain a 'document_id' attribute.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(./location)=1"/>
      <axsl:otherwise>Element 'object' must contain one 'location' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="object[name(..) != 'context']" priority="3991" mode="M0">
    <axsl:choose>
      <axsl:when test="count(published|language_id|data_format_id|title|creation_timestamp|location|marked_new|notes|attributes|abstract|body|department_id|keywords|style_id|symname_to_doc_id|created_by_id|locked_by_id|last_modified_by_id|last_modified_by_lastname|last_modified_by_middlename|last_modified_by_firstname|created_by_lastname|created_by_middlename|created_by_firstname|owned_by_lastname|owned_by_middlename|owned_by_firstname|last_publication_timestamp|last_published_by_id|last_published_by_lastname|last_published_by_middlename|last_published_by_firstname|schema_id|document_role)                   =count(*)"/>
      <axsl:otherwise>Foreign element child<axsl:text xml:space="preserve"> </axsl:text><axsl:value-of select="name(.)"/><axsl:text xml:space="preserve"> </axsl:text>in element 'object'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="user-privileges" priority="3990" mode="M0">
    <axsl:choose>
      <axsl:when test="count(view)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'view' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(write)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'write' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(delete)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'delete' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(publish)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'publish' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(attributes)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'attributes' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(translate)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'translate' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(create)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'create' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(move)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'move' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(link)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'link' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(publish_all)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'publish_all' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(attributes_all)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'attributes_all' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(delete_all)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'delete_all' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(grant)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'grant' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(grant_all)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'grant_all' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(owner)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'owner' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(master)=1"/>
      <axsl:otherwise>Element 'user-privileges' must contain one 'master' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(view|write|delete|publish|attributes|translate|create|move|link|                         publish_all|attributes_all|delete_all|grant|grant_all|owner|master)                   =count(*)"/>
      <axsl:otherwise>Foreign element child in element 'user-privileges'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="user" priority="3989" mode="M0">
    <axsl:choose>
      <axsl:when test="@id"/>
      <axsl:otherwise>Element 'user' must contain an 'id' attribute.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(lastname)=1"/>
      <axsl:otherwise>Element 'user' must contain one 'lastname' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(enabled)=1"/>
      <axsl:otherwise>Element 'user' must contain one 'enabled' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(name)=1"/>
      <axsl:otherwise>Element 'user' must contain one 'name' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(admin)=1"/>
      <axsl:otherwise>Element 'user' must contain one 'admin' element.</axsl:otherwise>
    </axsl:choose>
    <axsl:choose>
      <axsl:when test="count(lastname|enabled|name|admin|object_privileges)=count(*)"/>
      <axsl:otherwise>Foreign element child in element 'user'.</axsl:otherwise>
    </axsl:choose>
    <axsl:apply-templates mode="M0"/>
  </axsl:template>
  <axsl:template match="text()" priority="-1" mode="M0"/>
  <axsl:template match="text()" priority="-1"/>
</axsl:stylesheet>
