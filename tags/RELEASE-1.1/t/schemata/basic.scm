<?xml version="1.0"?>
<schema xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<pattern name="Basic XIMS application DOM checks">
  <rule context="/*">
    <assert test="name()='document'">The top level element must be named 'document'.</assert>
  </rule>
  <rule context="document">
    <assert test="count(context|objectlist|userlist|language|object-types|data-formats)=count(../*)">
      Foreign element child <name path="."/> in element 'document'.
    </assert>
  </rule>
  <rule context="session">
    <assert test="count(last_access_timestamp)=1">The 'session' element must contain a 'last_access_timestamp' element.</assert>
    <assert test="count(host)=1">The 'session' element must contain a 'host' element.</assert>
    <assert test="count(user)=1">The 'session' element must contain a 'user' element.</assert>
    <assert test="count(date)=1">The 'session' element must contain a 'date' element.</assert>
    <assert test="count(last_access_timestamp|host|user|user_id|date|error_msg|warning_msg|message|verbose_msg|skin|uilanguage|session_id|attributes|serverurl|searchresultcount)=count(./*)">
      Foreign element child <name path="."/> in element 'session'.
    </assert>
  </rule>
  <rule context="context">
    <assert test="count(session|object)=count(*)">
      Foreign element child <name/> in element 'context'.
    </assert>
  </rule>
  <rule context="objectlist">
    <assert test="count(object)=count(*)">
      Foreign element child <name/> in element 'objectlist'.
    </assert>
  </rule>
  <rule context="userlist">
    <assert test="count(user) &gt; 0">
      Element 'userlist' must contain at least one 'user' element.
    </assert>
    <assert test="count(user)=count(*)">
      Foreign element child <name/> in element 'userlist'.
    </assert>
  </rule>
  <rule context="language">
    <assert test="count(fullname)=1">The 'language' element must contain one 'fullname' element.</assert>
    <assert test="count(code)=1">The 'language' element must contain one 'code' element.</assert>
    <assert test="count(fullname|code)=count(*)">
      Foreign element child <name/> in element 'language'.
    </assert>
  </rule>
  <rule context="object-types">
    <assert test="count(object-type)=count(*)">
      Foreign element child <name/> in element 'object-types'.
    </assert>
  </rule>

  <!-- object element rules -->
  <rule context="object[name(..) = 'context']">
    <assert test="@id">Element 'object' must contain an 'id' attribute.</assert>
    <assert test="@document_id">Element 'object' must contain a 'document_id' attribute.</assert>
    <assert test="count(./location)=1">Element 'object' must contain one 'location' element.</assert>
  </rule>
  <rule context="object[name(..) = 'context']">
    <assert test="count(parents|body|location_path|data_format_id|last_published_by_id|last_published_by_firstname|script_id|status|owned_by_middlename|published|abstract|object_type_id|owned_by_id|image_id|location|last_publication_timestamp|title|last_modified_by_middlename|last_modification_timestamp|style_id|created_by_id|last_modified_by_id|user_privileges|created_by_firstname|locked_by_middlename|marked_new|last_modified_by_lastname|marked_deleted|css_id|last_published_by_lastname|owned_by_lastname|creation_timestamp|last_modified_by_firstname|language_id|attributes|keywords|notes|symname_to_doc_id|locked_time|data_format_name|locked_by_lastname|owned_by_firstname|created_by_middlename|last_published_by_middlename|locked_by_firstname|created_by_lastname|department_id|children|position|locked_by_id|schema_id|document_status|valid_from_timestamp|valid_to_timestamp)=count(*)">
      Foreign element child <name/> in element 'object'.
    </assert>
  </rule>

  <rule context="user-privileges">
    <assert test="count(view)=1">Element 'user-privileges' must contain one 'view' element.</assert>
    <assert test="count(write)=1">Element 'user-privileges' must contain one 'write' element.</assert>
    <assert test="count(delete)=1">Element 'user-privileges' must contain one 'delete' element.</assert>
    <assert test="count(publish)=1">Element 'user-privileges' must contain one 'publish' element.</assert>
    <assert test="count(attributes)=1">Element 'user-privileges' must contain one 'attributes' element.</assert>
    <assert test="count(translate)=1">Element 'user-privileges' must contain one 'translate' element.</assert>
    <assert test="count(create)=1">Element 'user-privileges' must contain one 'create' element.</assert>
    <assert test="count(move)=1">Element 'user-privileges' must contain one 'move' element.</assert>
    <assert test="count(link)=1">Element 'user-privileges' must contain one 'link' element.</assert>
    <assert test="count(publish_all)=1">Element 'user-privileges' must contain one 'publish_all' element.</assert>
    <assert test="count(attributes_all)=1">Element 'user-privileges' must contain one 'attributes_all' element.</assert>
    <assert test="count(delete_all)=1">Element 'user-privileges' must contain one 'delete_all' element.</assert>
    <assert test="count(grant)=1">Element 'user-privileges' must contain one 'grant' element.</assert>
    <assert test="count(grant_all)=1">Element 'user-privileges' must contain one 'grant_all' element.</assert>
    <assert test="count(owner)=1">Element 'user-privileges' must contain one 'owner' element.</assert>
    <assert test="count(master)=1">Element 'user-privileges' must contain one 'master' element.</assert>
    <assert test="count(view|write|delete|publish|attributes|translate|create|move|link|
                        publish_all|attributes_all|delete_all|grant|grant_all|owner|master)
                  =count(*)">
      Foreign element child in element 'user-privileges'.
    </assert>
  </rule>
  <rule context="user">
    <assert test="@id">Element 'user' must contain an 'id' attribute.</assert>
    <assert test="count(lastname)=1">Element 'user' must contain one 'lastname' element.</assert>
    <assert test="count(middlename)=1">Element 'user' must contain one 'middlename' element.</assert>
    <assert test="count(firstname)=1">Element 'user' must contain one 'firstname' element.</assert>
    <assert test="count(enabled)=1">Element 'user' must contain one 'enabled' element.</assert>
    <assert test="count(name)=1">Element 'user' must contain one 'name' element.</assert>
    <assert test="count(admin)=1">Element 'user' must contain one 'admin' element.</assert>
    <assert test="count(email)=1">Element 'user' must contain one 'email' element.</assert>
    <assert test="count(object_type)=1">Element 'user' must contain one 'object_type' element.</assert>
    <assert test="count(url)=1">Element 'user' must contain one 'url' element.</assert>
    <assert test="count(system_privs_mask)=1">Element 'user' must contain one 'system_privs_mask' element.</assert>
    <assert test="count(dav_otprivs_mask)=1">Element 'user' must contain one 'dav_otprivs_mask' element.</assert>
    <assert test="count(lastname|middlename|firstname|enabled|name|admin|email|object_type|url|system_privs_mask|dav_otprivs_mask)=count(*)">
      Foreign element child in element 'user'.
    </assert>
  </rule>
</pattern>
</schema>
