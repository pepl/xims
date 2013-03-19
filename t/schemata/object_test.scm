<?xml version="1.0"?>
<schema xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<pattern name="Object tests">
  <rule context="context">
    <assert test="count(object)=1">The context element must have a 'object' child.</assert>
  </rule>
  <rule context="context/object">
     <assert test="count(title)=1">Object element must contain a 'title' child.</assert>
     <assert test="title/text()='xims'">The 'title' element should be have the value 'xims'.</assert>
  </rule>
</pattern>
</schema>
