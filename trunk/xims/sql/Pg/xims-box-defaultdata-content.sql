-- add SiteRoot 'xims' with SiteRoot URL 'http://www.xims-default.tld:9555' # doc_id=2
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 1, 19, 31, 2, 'xims', 1, '/xims');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id )
	VALUES (nextval('ci_content_id_seq'), 2, 'http://www.xims-default.tld:9555', 2, 2, 2, 2);

-- add SiteRoot 'examplesite' with SiteRoot URL 'http://www.examplesite-xims.tld:9555' # doc_id=3
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 1, 19, 31, 2, 'examplesite', 2, '/examplesite');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body, published )
	VALUES (nextval('ci_content_id_seq'), 3, 'http://www.examplesite-xims.tld:9555', 2, 2, 2, 2, '<portlet>15</portlet>', 1);

-- add Folder 'stylesheets' to 'examplesite' SiteRoot # doc_id=4
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 3, 1, 18, 3, 'stylesheets', 1, '/examplesite/stylesheets');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published )
	VALUES (nextval('ci_content_id_seq'), 4, 'stylesheets', 2, 2, 2, 2, 1);

-- add Folder 'pubstylesheets' to 'examplesite' SiteRoot # doc_id=5
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 3, 1, 18, 3, 'pubstylesheets', 2, '/examplesite/pubstylesheets');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published )
	VALUES (nextval('ci_content_id_seq'), 5, 'pubstylesheets', 2, 2, 2, 2, 1);
-- update style_id of 'examplesite' SiteRoot
UPDATE ci_content SET style_id = 5 WHERE id = 3;

-- add XSL-T stylesheet 'default.xsl' to 'stylesheets'-folder in 'examplesite' # doc_id=6
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 4, 7, 3, 3, 'default.xsl', 1, '/examplesite/stylesheets/default.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, body )
	VALUES (nextval('ci_content_id_seq'), 6, 'default.xsl', 2, 2, 2, 2, 1, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcq="http://purl.org/dc/qualifiers/1.0/" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="date" exclude-result-prefixes="rdf dc dcq #default" version="1.0">

<xsl:output method="xml" encoding="UTF-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:param name="request.uri.query"/>
<xsl:param name="request.uri"/>

<xsl:template match="/page">
    <html>
    <head>
        <title><xsl:value-of select="rdf:RDF/rdf:Description/dc:title/text()"/></title>
        <!-- We have to use an absolute URI here so that the CSS stylesheet will also be found during publishing preview and other goxims-served events -->
        <link type="text/css" rel="stylesheet" href="/stylesheets/default.css"/>
        <link type="text/css" rel="stylesheet" href="/ximspubroot/examplesite/stylesheets/default.css"/>
    </head>
    <body>
        <xsl:comment>UdmComment</xsl:comment>
        <div id="header">
            <xsl:call-template name="banner"/>
            <div id="departmentlinks">
                <xsl:call-template name="departmentlinks"/>
            </div>
        </div>
        <div id="content">
            <xsl:comment>/UdmComment</xsl:comment>
            <xsl:apply-templates select="body"/>
        </div>
        <div id="footer">
            <span class="left">
                © 2003-<xsl:value-of select="date:year()"/> Grey Dahut Preservation Initiative<br/> www.examplesite-xims.tld
            </span>
            <span class="right">
                Powered by
                <a href="http://axkit.org/">Apache AxKit</a>
                &amp;
                <a href="http://xims.info/">XIMS</a>
            </span>
        </div>

      </body>
    </html>
</xsl:template>

<xsl:template name="banner">
    <div id="banner">
        <div id="pathnavigation">
            <xsl:call-template name="pathnavigation"/>
        </div>
        <div id="logo">
            Grey Dahut Preservation Initiative
        </div>
    </div>
</xsl:template>

<xsl:template match="abbr|acronym|address|b|bdo|big|blockquote|br|cite|code|div|del|dfn|em|hr|h1|h2|h3|h4|h5|h6|i|ins|kbd|p|pre|q|samp|small|span|strong|sub|sup|tt|var|         dl|dt|dd|li|ol|ul|         a|         img|map|area|         caption|col|colgroup|table|tbody|td|tfoot|th|thead|tr|         button|fieldset|form|label|legend|input|option|optgroup|select|textarea|         applet|object|param|embed|script">
    <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
        <xsl:for-each select="@*">
             <xsl:attribute name="{name(.)}">
                  <xsl:value-of select="."/>
             </xsl:attribute>
        </xsl:for-each>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template name="pathnavigation">
    <xsl:param name="string" select="$request.uri"/>
    <xsl:param name="pattern" select="''/''"/>

    <xsl:choose>
        <xsl:when test="contains($string, $pattern)">
            <xsl:if test="not(starts-with($string, $pattern))">
                <xsl:call-template name="pathnavigation">
                   <xsl:with-param name="string" select="substring-before($string, $pattern)"/>
                   <xsl:with-param name="pattern" select="$pattern"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="pathnavigation">
                <xsl:with-param name="string" select="substring-after($string, $pattern)"/>
                <xsl:with-param name="pattern" select="$pattern"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$string = ''_ottereendex.html''">
                     /
                </xsl:when>
                <xsl:when test="contains($request.uri, concat($string,''/''))">
                     / <a><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''''"><xsl:value-of select="concat(substring-before($request.uri, concat($string,''/'')),$string,''/'')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat(substring-before($request.uri, concat($string,''/'')),$string,''/'',''?'',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="contains($string,''.html'')">
                                    <xsl:value-of select="substring-before($string,''.html'')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$string"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                </xsl:when>
                <xsl:otherwise>
                     / <a><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''''"><xsl:value-of select="$request.uri"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($request.uri, ''?'',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="contains($string,''.html'')">
                                    <xsl:value-of select="substring-before($string,''.html'')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$string"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                </xsl:otherwise>
            </xsl:choose>
       </xsl:otherwise>
     </xsl:choose>
</xsl:template>

<xsl:template name="departmentlinks">
    <xsl:if test="ou/portlet[title = ''departmentlinks_portlet'']/portlet-item">
        <ul>
             <xsl:apply-templates select="ou/portlet[title = ''departmentlinks_portlet'']/portlet-item">
                <xsl:sort select="position" data-type="number" order="ascending"/>
             </xsl:apply-templates>
        </ul>
  </xsl:if>
</xsl:template>

<xsl:template match="portlet-item">
    <li>
        <a>
            <xsl:attribute name="href"><xsl:value-of select="location"/></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="abstract"/></xsl:attribute>
            <xsl:value-of select="title"/>
        </a>
    </li>
</xsl:template>

</xsl:stylesheet>
');

-- add CSS stylesheet 'default.css' to 'stylesheets'-folder in 'examplesite' # doc_id=7
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 4, 21, 5, 3, 'default.css', 2, '/examplesite/stylesheets/default.css');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, body )
	VALUES (nextval('ci_content_id_seq'), 7, 'default.css', 2, 2, 2, 2, 1, 'body, html, div {
    margin: 0;
    padding: 0;
}

body {
    font: 10pt/16pt helvetica, arial, sans-serif;
    width:790px;
}

h1, h2, h3, h4, h5, h6 {
    border-bottom: 1px solid #eeeeee;
    text-align: justify;
    color: #006600;
}

h1 {
    font: bolder 16pt/16pt helvetica, arial, sans-serif;
}

h2 {
    font: bolder 14pt/14pt verdana, geneva, arial, sans serif;
}

h3 {
    font: bolder 12pt/12pt verdana, geneva, arial, sans serif;
}

p {
    font: 10pt/14pt helvetica, arial, sans-serif;
    text-align: justify;
    margin-bottom: 8pt;
    margin-top: 8pt;
}

a:link {
    color: #333399;
}

a:visited {
    color: #000033;
}

a:hover {
    color: #333399;
}

.pseudolink {
    color: #333399;
    text-decoration:underline;
}

.left {
    float: left;
}
.right {
    float: right;
}

#header {
    background:#fff;
    border-top:1px;
    border-right:1px;
    border-left:1px;
    voice-family: &quot;\\&quot;}\\&quot;&quot;;
    voice-family: inherit;
}

#banner {
    background: #99CC99;
    font: bold 16pt/16pt helvetica, arial, sans-serif;
    padding: 0px 0px 0px 10px;
    color: #669966;
}

#logo {
    text-align: right;
}

#pathnavigation {
    position: absolute;
    left:10px;
    color: #000000;
    font: 10pt/16pt helvetica, arial, sans-serif;
}

#pathnavigation a {
    color: #000000;
    text-decoration:none;
}

#content {
    padding: 10px 0px 0px 10px;
    width:770px;
}

#footer {
    font: 7pt/7pt helvetica, arial, sans-serif;
    color: #a9a9a9;
    margin-top: 50px;
    padding: 0px 0px 0px 10px;
}

#footer a {
    text-decoration: none;
}

#departmentlinks {
    background: #F5F7F4;
    padding: 0px 0px 0px 10px;
}

#departmentlinks ul {
    margin: 0;
    padding: 0;
}

#departmentlinks li {
    display:inline;
    padding: 0px 5px 0px 0px;
    margin: 0;
    border: 1px solid #eeeeee;
    border-top-color: #99CC99;
}

#departmentlinks a {
    text-decoration:none;
    padding: 0px 0px 0px 0px;
}

#departmentlinks a:link {
    color: #333399;
}

#departmentlinks a:visited {
    color: #000033;
}

#departmentlinks a:hover {
    background: #EFF7EB;
    color: #699364;
}

');

-- add XSL-T stylesheet 'error.xsl' to 'stylesheets'-folder in 'examplesite' # doc_id=8
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 4, 7, 3, 3, 'error.xsl', 1, '/examplesite/stylesheets/error.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, body )
	VALUES (nextval('ci_content_id_seq'), 8, 'error.xsl', 2, 2, 2, 2, 1, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/xhtml1/strict" version="1.0">
    <xsl:output method="html" encoding="ISO-8859-1"/>

    <xsl:template match="bt">

        <tr>
            <xsl:if test="position() mod 2">
                <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
            </xsl:if>
            <td>
                <xsl:value-of select="@level"/>
            </td>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="file|line">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="/">
        <html>
            <head>
                <title>Server Error</title>
                <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css"/>
            </head>
            <body>
                <h1>Server Error</h1>
                <p>The following error occurred: <xsl:value-of select="/error/msg"/></p>
                <h2>Stack Trace:</h2>
                <table>
                    <tr bgcolor="blue"><th>Level</th><th>File</th><th>Line #</th></tr>

                    <xsl:apply-templates select="/error/stack_trace/*"/>

                </table>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
');

-- add XSL-T stylesheet 'document_publishing_preview.xsl' to 'pubstylesheets'-folder in 'examplesite' # doc_id=9
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 5, 7, 3, 3, 'document_publishing_preview.xsl', 1, '/examplesite/pubstylesheets/document_publishing_preview.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, body )
	VALUES (nextval('ci_content_id_seq'), 9, 'document_publishing_preview.xsl', 2, 2, 2, 2, 1, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
    <!-- libxslt does not like .tld addresses, so for this example we will use a filesystem URI -->
    <!-- <xsl:import href="http://simple.examplesite.tld/stylesheets/default.xsl"/>-->
    <xsl:import href="/opt/xims-package/xims/www/ximspubroot/examplesite/stylesheets/default.xsl"/>

    <!--
         To disable the links outside of the source document - specified by the stylesheet -,
         the corresponding templates would have to be overriden.
    -->
    <xsl:template match="a">
        <span class="pseudolink"><xsl:value-of select="text()"/></span>
    </xsl:template>
</xsl:stylesheet>
');

-- add Document 'index.html' to 'examplesite' # doc_id=10
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 3, 2, 2, 3, 'index.html', 3, '/examplesite/index.html');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, abstract, keywords, body )
	VALUES (nextval('ci_content_id_seq'), 10, 'index', 2, 2, 2, 2, 1, 'Home of the Grey Dahut Preservation Initiative', 'dahut; grey dahut; gdpi', '
<h1>Welcome to Grey Dahut Preservation Initiative (GDPI)</h1>

<p>The GDPI aims to the preserve the endagered population and
habitat of the Grey Dahut.</p>

<p>In contrast to regular Dahuts, Grey Dahuts have been far
more radically decimated in the Great Hunts of the late 20th
century because of their easy to spot grey-colored fur in the
electronic-snow covered glaciers of the virtual alps.</p>

<p>The GDPI has already successfully started repopulation and
is still heavily working on further progress.</p>

<p>For details about the GDPI and to learn how to participate
or contribute, visit the <a href="about.html">About
Page</a>.</p>

<p>View the published version of GDPI at: <a href="http://www.examplesite-xims.tld:9555">http://www.examplesite-xims.tld:9555</a></p>
');

-- add Document 'contact.html' to 'examplesite' # doc_id=11
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 3, 2, 2, 3, 'contact.html', 4, '/examplesite/contact.html');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, abstract, keywords, body )
	VALUES (nextval('ci_content_id_seq'), 11, 'contact', 2, 2, 2, 2, 1, 'Contact information', 'dahut; grey dahut; gdpi', '<h1>Contact</h1>
        <p>
        Visit <a href="irc://irc.perl.org/axkit-dahut">#axkit-dahut</a> and ask for "Dahut".
        </p>
');

-- add Document 'team.html' to 'examplesite' # doc_id=12
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 3, 2, 2, 3, 'team.html', 5, '/examplesite/team.html');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, abstract, keywords, body )
	VALUES (nextval('ci_content_id_seq'), 12, 'team', 2, 2, 2, 2, 1, 'Team members of the GDPI', 'dahut; grey dahut; gdpi', '<h1>Team</h1>
        <table cellpadding="4">
            <tr>
                <td height="130" width="150" bgcolor="#eeeeee" border="1" align="center" valign="center">
                    <div style="font-size: 0.8em; font-color: #dddddd; padding: 5px;">Picture undisclosed</div>
                </td>
                <td valign="top">
                    <h2>Bender</h2>
                    <p>
                        His magnifient highness, Bender, does not let any questions be unanswered.<br/>
                        Visit him at <a href="irc://irc.perl.org/axkit-dahut">#axkit-dahut</a>.
                    </p>
                </td>
            </tr>
        </table>
        <p>
        For security reasons, the identity of other members of the GDPI remains undisclosed at this location. You may however <a href="contact.html">contact</a> the GDPI if you seriously consider to participate.
        </p>
');

-- add Document 'about.html' to 'examplesite' # doc_id=13
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 3, 2, 2, 3, 'about.html', 6, '/examplesite/about.html');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, abstract, keywords, body )
	VALUES (nextval('ci_content_id_seq'), 13, 'about', 2, 2, 2, 2, 1, 'About the GDPI', 'dahut; grey dahut; gdpi', '<h1>About</h1>

        <p>The GDPI is backed by dahut.pm</p>
        <p>Contribute by joining <a href="irc://irc.perl.org/axkit-dahut">#axkit-dahut</a> and shouting "DAAAHUUUTTT!!!". Bender, the Grande Lider of both the GDPI and dahut.pm will kindly answer and donate money to PayPal for the GDPI Support Fund.</p>
        <p>To get more details, consult the <a href="team.html">team</a>.
        </p>
');

-- add Folder 'departmentlinks' to 'examplesite' SiteRoot # doc_id=14
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 3, 1, 18, 3, 'departmentlinks', 7, '/examplesite/departmentlinks');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published )
	VALUES (nextval('ci_content_id_seq'), 14, 'departmentlinks', 2, 2, 2, 2, 1);

-- add Portlet 'departmentlinks_portlet' to 'examplesite' SiteRoot # doc_id=15
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path, symname_to_doc_id )
	VALUES (nextval('ci_documents_id_seq'), 3, 17, 29, 3, 'departmentlinks_portlet.ptlt', 8, '/examplesite/departmentlinks_portlet.ptlt', 14);
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, abstract, body )
	VALUES (nextval('ci_content_id_seq'), 15, 'departmentlinks_portlet', 2, 2, 2, 2, 1, 'departmentlinks_portlet', '<content><column name="abstract"/><object-type name="URLLink"/><object-type name="URLLink"/></content>
<filter>
</filter>
');

-- add URLLink 'Home' to folder 'departmentlinks' in 'examplesite' SiteRoot # doc_id=16
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 14, 11, 22, 3, '/index.html', 1, '/examplesite//index.html');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, status )
	VALUES (nextval('ci_content_id_seq'), 16, 'Home', 2, 2, 2, 2, 1, '400 URL must be absolute');

-- add URLLink 'About' to folder 'departmentlinks' in 'examplesite' SiteRoot # doc_id=17
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 14, 11, 22, 3, '/about.html', 2, '/examplesite/about.html');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, status )
	VALUES (nextval('ci_content_id_seq'), 17, 'About', 2, 2, 2, 2, 1, '400 URL must be absolute');

-- add URLLink 'Team' to folder 'departmentlinks' in 'examplesite' SiteRoot # doc_id=18
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 14, 11, 22, 3, '/team.html', 3, '/examplesite/team.html');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, status )
	VALUES (nextval('ci_content_id_seq'), 18, 'Team', 2, 2, 2, 2, 1, '400 URL must be absolute');

-- add URLLink 'Contact' to folder 'departmentlinks' in 'examplesite' SiteRoot # doc_id=19
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 14, 11, 22, 3, '/contact.html', 4, '/examplesite/contact.html');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, published, status )
	VALUES (nextval('ci_content_id_seq'), 19, 'Contact', 2, 2, 2, 2, 1, '400 URL must be absolute');

-- add Document 'index.html' to 'xims' # doc_id=20
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 2, 2, 2, 2, 'index.html', 1, '/xims/index.html');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 20, 'index', 2, 2, 2, 2, '<h1>Home: www.xims-default.tld:9555<br /></h1>
<p>This is home of the xims default site!<br /></p>
<p><b>Please Note:</b> In order to get this document displayed properly when
published you need to publish
the stylesheets-folder first!</p>');

-- add Folder 'stylesheets' to 'xims' SiteRoot # doc_id=21
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 2, 1, 18, 2, 'stylesheets', 2, '/xims/stylesheets');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id )
	VALUES (nextval('ci_content_id_seq'), 21, 'stylesheets', 2, 2, 2, 2);

-- add XSL-T stylesheet 'default.xsl' to 'stylesheets'-folder in 'xims' # doc_id=22
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 21, 7, 3, 2, 'default.xsl', 1, '/xims/stylesheets/default.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 22, 'default.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcq="http://purl.org/dc/qualifiers/1.0/" xmlns="http://www.w3.org/1999/xhtml" version="1.0" exclude-result-prefixes="rdf dc dcq #default">
<!--$Id: default.xsl 1176 2005-07-01 16:07:45Z pepl $-->

<xsl:import href="include/default_header.xsl"/>
<xsl:import href="include/common.xsl"/>

<xsl:output method="xml" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/page">
    <html>
    <head>
      <xsl:call-template name="meta"/>
      <meta name="MSSmartTagsPreventParsing" content="TRUE"/>
      <meta http-equiv="imagetoolbar" content="no"/>
      <title><xsl:value-of select="rdf:RDF/rdf:Description/dc:title/text()"/></title>
      <link rel="stylesheet" href="/stylesheets/default.css" type="text/css"/>
      <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css"/>
      <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css"/>
    </head>
    <body>
        <xsl:comment>UdmComment</xsl:comment>
        <xsl:call-template name="header"/>
        <div id="leftcontent">
            <xsl:call-template name="stdlinks"/>
            <xsl:call-template name="departmentlinks"/>
            <xsl:call-template name="documentlinks"/>
        </div>
        <div id="centercontent">
            <xsl:comment>/UdmComment</xsl:comment>
            <xsl:apply-templates select="body"/>
            <div id="footer">
                <span class="left">
                    <xsl:call-template name="copyfooter"/>
                </span>
                <span class="right">
                    <xsl:call-template name="powerdbyfooter"/>
                </span>
            </div>
        </div>
      </body>
    </html>
</xsl:template>

</xsl:stylesheet>
');

-- add XSL-T stylesheet 'default_print.xsl' to 'stylesheets'-folder in 'xims' # doc_id=23
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 21, 7, 3, 2, 'default_print.xsl', 2, '/xims/stylesheets/default_print.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 23, 'default_print.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcq="http://purl.org/dc/qualifiers/1.0/" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
<!--$Id: default_print.xsl 908 2004-11-09 01:19:45Z pepl $-->

<xsl:import href="include/common.xsl"/>
<xsl:param name="request.headers.host"/>
<xsl:param name="links"/>

<xsl:output method="html" encoding="utf-8"/>

<xsl:template match="/page">
    <html>
    <head>
      <xsl:call-template name="meta"/>
      <title><xsl:value-of select="rdf:RDF/rdf:Description/dc:title/text()"/></title>
      <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css"/>
      <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css"/>
    </head>

    <body>
	<p class="printzitat">
        Document:<br/>
      	<xsl:value-of select="rdf:RDF/rdf:Description/dc:creator"/>,
      	<xsl:value-of select="rdf:RDF/rdf:Description/dc:title"/>,
    	[<xsl:value-of select="concat(''http://'',$request.headers.host,$request.uri)"/>],
    	<!-- http:// ist fest mitcodiert, da kein dafür kein geeigneter funktionierender Parameter gefunden wurde -->
     	<xsl:value-of select="rdf:RDF/rdf:Description/dc:date/dcq:modified/rdf:Description/rdf:value"/>
      	<!-- hier sollte das aktulle Tagesdatum stehen; ist zum gegenwärtigen Zeitpunkt noch nicht verfügbar -->
     	<br/><br/>
	<xsl:choose>
            	<xsl:when test="$links=''1''">
                	<a href="{$request.uri}?style=print">fade out linklist</a> |
             	</xsl:when>
             	<xsl:otherwise>
                    <a href="{$request.uri}?style=print;links=1">show linklist</a> |
            	</xsl:otherwise>
   	</xsl:choose>
      	<a href="javascript:print()">print document</a> |
      	<a href="{$request.uri}">back to htmlversion</a>
    	</p>
       <hr/>

      	<!-- Begin content -->
	<table>
	   	<tr>
	            <td class="printzitatContent">
	                <xsl:apply-templates select="body"/>
	            </td>
	        </tr>
	</table>

	<xsl:if test="$links=''1''">
        <hr/>
         <table class="printzitat">
            <tr>
                <th style="background-color:#ffffff; text-align:left;">Documentlinks</th>
            </tr>

             <xsl:choose>
                    <xsl:when test="//a">
                        <xsl:for-each select="//a">
                        <tr>
                            <td>[<xsl:number level="any"/>] <xsl:value-of select="@href"/></td>
                        </tr>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                            <tr>
                                <td>there are no links in this document</td>
                            </tr>
                    </xsl:otherwise>
               </xsl:choose>

              </table>
    	</xsl:if>
      	<!-- End content -->

      </body>
    </html>
</xsl:template>


<xsl:template match="a">
    <xsl:choose>
    <xsl:when test="$links=''1''">
         <a href="{@href}"><xsl:value-of select="text()"/></a> [<xsl:number level="any"/>]
    </xsl:when>
    <xsl:otherwise>
         <xsl:copy>
               <xsl:copy-of select="@*"/>
               <xsl:apply-templates/>
        </xsl:copy>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>
');

-- add XSL-T stylesheet 'default_textonly.xsl' to 'stylesheets'-folder in 'xims' # doc_id=24
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 21, 7, 3, 2, 'default_textonly.xsl', 3, '/xims/stylesheets/default_textonly.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 24, 'default_textonly.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcq="http://purl.org/dc/qualifiers/1.0/" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
<!--$Id: default_textonly.xsl 908 2004-11-09 01:19:45Z pepl $-->

<xsl:import href="include/common.xsl"/>

<xsl:output method="html" encoding="ISO-8859-1"/>

<xsl:template match="/page">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de">
    <head>
      <xsl:call-template name="meta"/>
      <title><xsl:value-of select="rdf:RDF/rdf:Description/dc:title/text()"/></title>
      <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css"/>
      <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css"/>
    </head>

    <body bgcolor="#ffffff" text="#000000" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
        <!--UdmComment-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%">

     <!-- Begin header -->
    <tr>
        <td bgcolor="#123853" width="75%">
            <span style="color:#ffffff; font-size:14pt;">The eXtensible Information Management System</span>
        </td>
            <td bgcolor="#123853" align="right" width="25%">
            <xsl:text> </xsl:text>
        </td>
        </tr>
        <tr>
            <td class="pathinfo">
                    <xsl:call-template name="pathinfo"/>
            </td>
            <td class="pathinfo" align="right">
                    <a href="{$request.uri}?style=print">[printversion]</a>
                <xsl:text>  </xsl:text>
                <a href="{$request.uri}">[html-version]</a>
            </td>
         </tr>
     <!-- End header -->
    <tr>
            <td colspan="2" style="padding-left:10px;">
                  Deptlinks navigation:<xsl:text> </xsl:text>
                  <xsl:call-template name="deptlinks">
                        <xsl:with-param name="mode">print</xsl:with-param>
                  </xsl:call-template>
            </td>
        </tr>
    <tr>
         <td valign="top" colspan="2" class="content">
                <br/><br/>
                <!--/UdmComment-->
                <xsl:apply-templates select="body"/>
         </td>
    </tr>
        <tr>
        <td colspan="2"> </td>
        </tr>
       <tr>
                <td valign="baseline" style="padding-left:10px;">
                    <xsl:call-template name="copyfooter"/>
                </td>
                <td valign="top" align="right" style="padding-right:10px;">
                    <xsl:call-template name="powerdbyfooter"/>
                </td>
    </tr>
        </table>
      </body>
    </html>
</xsl:template>


<xsl:template match="link">
    <a href="{@href}/?style=textonly"><xsl:value-of select="text()"/></a><xsl:text>   </xsl:text>
</xsl:template>

<xsl:template match="img">
    <xsl:choose>
        <xsl:when test="@alt != ''''">
            [Image: <xsl:value-of select="//img/@alt"/>]
        </xsl:when>
        <xsl:otherwise>
            [Image: No description available]
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="a">
    <a>
        <xsl:if test="@href != ''''">
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="contains(@href = ''?'')">
                        <xsl:value-of select="concat(@href,''&amp;style=textonly'')"/>
                    </xsl:when>
                    <xsl:when test="contains(@href, ''#'')">
                        <xsl:value-of select="@href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(@href,''?style=textonly'')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="title">
            <xsl:choose>
                <xsl:when test="@title != ''''">
                    <xsl:value-of select="@title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:if test="@target != ''''">
            <xsl:attribute name="target">
                <xsl:value-of select="@target"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@name != ''''">
            <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@id != ''''">
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@class != ''''">
            <xsl:attribute name="class">
                <xsl:value-of select="@class"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </a>
</xsl:template>
</xsl:stylesheet>
');

-- add XSL-T stylesheet 'portlet_rss1.xsl' to 'stylesheets'-folder in 'xims' # doc_id=25
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 21, 7, 3, 2, 'portlet_rss1.xsl', 4, '/xims/stylesheets/portlet_rss1.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 25, 'portlet_rss1.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:date="http://exslt.org/dates-and-times" xmlns:exslt="http://exslt.org/common" version="1.0" extension-element-prefixes="exslt date">

    <xsl:output method="xml"/>

    <xsl:variable name="sorteditems">
        <xsl:for-each select="/portlet/portlet-item">
            <xsl:sort select="concat(valid_from_timestamp/year,valid_from_timestamp/month,valid_from_timestamp/day,valid_from_timestamp/hour,valid_from_timestamp/minute,valid_from_timestamp/second)" order="descending"/>
            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
            <xsl:sort select="position" order="ascending"/>
            <xsl:sort select="concat(creation_timestamp/year,creation_timestamp/month,creation_timestamp/day,creation_timestamp/hour,creation_timestamp/minute,creation_timestamp/second)" order="descending"/>
            <xsl:copy>
                <xsl:copy-of select="@*|*"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>

    <xsl:param name="request.headers.host"/>

    <xsl:template match="/portlet">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://purl.org/rss/1.0/" xmlns:dc="http://purl.org/dc/elements/1.1/">
            <channel rdf:about="http://xims.info/">
                <title>
                    <xsl:value-of select="title"/>
                </title>
                <link>http://xims.info/</link>
                <description>
                    <xsl:apply-templates select="abstract"/>
                </description>
                <image rdf:about="http://xims.info/images/powered_by_xims.gif">
                    <title>XIMS Web Content Management System</title>
                    <url>http://xims.info/images/powered_by_xims.gif</url>
                    <link>http://xims.info/</link>
                </image>
                <xsl:call-template name="dcmeta"/>
                <items>
                    <rdf:Seq>
                        <xsl:apply-templates select="exslt:node-set($sorteditems)/portlet-item" mode="seq"/>
                    </rdf:Seq>
                </items>
            </channel>
            <xsl:apply-templates select="exslt:node-set($sorteditems)/portlet-item" mode="item"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="portlet-item" mode="seq">
        <rdf:li xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <xsl:attribute name="rdf:resource">
                <xsl:if test="not( contains(location,''://''))">http://xims.info</xsl:if><xsl:value-of select="location_path"/>
            </xsl:attribute>
        </rdf:li>
    </xsl:template>

    <xsl:template match="portlet-item" mode="item">
        <item xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <xsl:attribute name="rdf:about">
                <xsl:if test="not( contains(location,''://''))">http://xims.info</xsl:if><xsl:value-of select="location_path"/>
            </xsl:attribute>
            <title>
                <xsl:value-of select="title"/>
            </title>
            <link><xsl:if test="not( contains(location,''://''))">http://xims.info</xsl:if><xsl:value-of select="location_path"/>
            </link>
            <dc:description xmlns:dc="http://purl.org/dc/elements/1.1/">
                <xsl:value-of select="abstract"/>
            </dc:description>
            <xsl:call-template name="dcmeta"/>
        </item>
    </xsl:template>

    <xsl:template name="dcmeta">
        <dc:publisher xmlns:dc="http://purl.org/dc/elements/1.1/">The XIMS Project</dc:publisher>
        <xsl:if test="owned_by_lastname != ''''">
            <dc:creator xmlns:dc="http://purl.org/dc/elements/1.1/"><xsl:value-of select="concat(owned_by_firstname, '' '',owned_by_lastname)"/></dc:creator>                    
        </xsl:if>
        <dc:rights xmlns:dc="http://purl.org/dc/elements/1.1/">Copyright © <xsl:value-of select="date:year()"/> The XIMS Project</dc:rights>
        <dc:date xmlns:dc="http://purl.org/dc/elements/1.1/"><xsl:apply-templates select="last_publication_timestamp" mode="ISO8601"/></dc:date>
    </xsl:template>

    <xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|valid_from_timestamp|valid_to_timestamp" mode="ISO8601">
        <xsl:value-of select="./year"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="./month"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="./day"/>
        <xsl:text>T</xsl:text>
        <xsl:value-of select="./hour"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="./minute"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="./second"/>
    </xsl:template>

</xsl:stylesheet>
');

-- add XSL-T stylesheet 'portlet_rss2.xsl' to 'stylesheets'-folder in 'xims' # doc_id=26
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 21, 7, 3, 2, 'portlet_rss2.xsl', 5, '/xims/stylesheets/portlet_rss2.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 26, 'portlet_rss2.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:date="http://exslt.org/dates-and-times" xmlns:exslt="http://exslt.org/common" version="1.0" extension-element-prefixes="exslt date">

<xsl:output method="xml"/>

<xsl:variable name="sorteditems">
    <xsl:for-each select="/portlet/portlet-item">
        <xsl:sort select="concat(valid_from_timestamp/year,valid_from_timestamp/month,valid_from_timestamp/day,valid_from_timestamp/hour,valid_from_timestamp/minute,valid_from_timestamp/second)" order="descending"/>
            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
            <xsl:sort select="position" order="ascending"/>
            <xsl:sort select="concat(creation_timestamp/year,creation_timestamp/month,creation_timestamp/day,creation_timestamp/hour,creation_timestamp/minute,creation_timestamp/second)" order="descending"/>
        <xsl:copy>
            <xsl:copy-of select="@*|*"/>
        </xsl:copy>
    </xsl:for-each>
</xsl:variable>

<xsl:param name="request.headers.host"/>

<xsl:template match="/portlet">
    <rss version="2.0">
        <channel>
            <title><xsl:value-of select="title"/></title>
            <link>http://xims.info/</link>
            <description><xsl:value-of select="abstract"/></description>
            <language>en</language>
            <pubDate><xsl:apply-templates select="valid_from_timestamp" mode="RFC822"/></pubDate>
            <lastBuildDate><xsl:apply-templates select="last_publication_timestamp" mode="RFC822"/></lastBuildDate>
            <copyright>Copyright © <xsl:value-of select="date:year()"/> The XIMS Project</copyright>
            <managingEditor>webmaster@xims.info</managingEditor>
            <webMaster>webmaster@xims.info</webMaster>
            <image>
                <title>XIMS Web Content Management System</title>
                <url>http://xims.info/images/powered_by_xims.gif</url>
                <link>http://xims.info/</link>
            </image>
            <generator>XIMS</generator>
            <xsl:apply-templates select="exslt:node-set($sorteditems)/portlet-item"/>
        </channel>
    </rss>
</xsl:template>

<xsl:template match="portlet-item">
    <item>
        <title><xsl:value-of select="title"/></title>
        <link><xsl:if test="not( contains(location,''://''))">http://xims.info</xsl:if><xsl:value-of select="location_path"/></link>
        <description><xsl:value-of select="abstract"/></description>
        <pubDate><xsl:apply-templates select="valid_from_timestamp" mode="RFC822"/></pubDate>
    </item>
</xsl:template>

<xsl:template match="last_modification_timestamp|date|lastaccess|creation_timestamp|locked_time|last_publication_timestamp|valid_from_timestamp|valid_to_timestamp" mode="RFC822">
    <xsl:variable name="datetime">
        <xsl:value-of select="./year"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="./month"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="./day"/>
        <xsl:text>T</xsl:text>
        <xsl:value-of select="./hour"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="./minute"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="./second"/>
        <!--<xsl:value-of select="./tzd"/>-->
    </xsl:variable>
    <xsl:variable name="hour" select="hour"/>
    <xsl:variable name="gmtdiff" select="''1''"/>
    <xsl:variable name="gmthour">
        <xsl:choose>
            <xsl:when test="number($hour)-number($gmtdiff) &lt; 0"><xsl:value-of select="number($hour)-number($gmtdiff)+24"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="number($hour)-number($gmtdiff)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="substring(date:day-name($datetime),1,3)"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="./day"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="date:month-abbreviation($datetime)"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="./year"/>
    <xsl:text> </xsl:text>
    <xsl:if test="string-length($gmthour)=1">0</xsl:if><xsl:value-of select="$gmthour"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./minute"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./second"/>
    <xsl:text> GMT</xsl:text>
</xsl:template>

</xsl:stylesheet>
');

-- add XSL-T stylesheet 'sdocbook_default.xsl' to 'stylesheets'-folder in 'xims' # doc_id=27
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 21, 7, 3, 2, 'sdocbook_default.xsl', 6, '/xims/stylesheets/sdocbook_default.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 27, 'sdocbook_default.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: sdocbook_default.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcq="http://purl.org/dc/qualifiers/1.0/" xmlns="http://www.w3.org/1999/xhtml" version="1.0">

<xsl:import href="include/default_header.xsl"/>
<xsl:import href="include/common.xsl"/>

<xsl:output method="html" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

<xsl:param name="section" select="''0''"/>
<xsl:param name="section-view" select="''false''"/>

<xsl:template match="/">
<html>
    <head>
        <title><xsl:value-of select="article/rdf:RDF/rdf:Description/dc:title/text()"/></title>
        <xsl:call-template name="meta">
          <xsl:with-param name="context_node" select="article"/>
        </xsl:call-template>
        <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css"/>
        <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css"/>
    </head>
    <body>
    <xsl:comment>UdmComment</xsl:comment>
    <xsl:call-template name="header"/>
    <div id="leftcontent">
        <xsl:call-template name="stdlinks"/>
        <xsl:call-template name="departmentlinks">
            <xsl:with-param name="context" select="article"/>
        </xsl:call-template>
    </div>
    <div id="centercontent">
        <xsl:comment>/UdmComment</xsl:comment>
            [<a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="$section-view=''true''">
                            <xsl:value-of select="concat(request.uri, ''?section-view=false'')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(request.uri, ''?section-view=true'')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                Toggle Multi-page View
            </a>
            ]
            <xsl:choose>
                <xsl:when test="$section &gt; 0 and $section-view=''true''">
                    <xsl:apply-templates select="article" mode="section-view"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="article"/>
                </xsl:otherwise>
            </xsl:choose>
        <xsl:comment>/UdmComment</xsl:comment>
        <div id="footer">
            <span class="left">
                <xsl:call-template name="copyfooter"/>
            </span>
            <span class="right">
                <xsl:call-template name="powerdbyfooter"/>
            </span>
        </div>
    </div>
    </body>
</html>
</xsl:template>

    <xsl:template match="article">
        <h1><xsl:value-of select="/article/title | /article/articleinfo/title"/></h1>

        <!-- begin frontmatter -->
        <p>By:
            <xsl:for-each select="articleinfo/authorgroup/author | articleinfo/author">
                <a href="mailto:{authorblurb/para/email}">
                    <xsl:value-of select="firstname"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="surname"/>
                </a>
                <xsl:if test="affiliation/orgname/text()"> (<xsl:value-of select="affiliation/orgname/text()"/>)</xsl:if>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </p>
        <xsl:apply-templates select="articleinfo/abstract/*"/>
        <!-- end frontmatter -->

        <!-- begin toc -->
        <div class="toc">
            <a name="toc"><h2>Contents</h2></a>
            <xsl:apply-templates select="(section)" mode="toc"/>
        </div>
        <!-- end toc -->

        <!-- begin main content -->

        <xsl:if test="$section-view=''false''">
            <div class="main-content">
                <xsl:apply-templates select="section"/>
            </div>
        </xsl:if>

        <!-- begin footer -->
        <xsl:call-template name="sdbkfooter"/>
        <!-- end footer -->

    </xsl:template>

    <xsl:template match="article" mode="section-view">
        <h1 class="section-title1"><xsl:value-of select="/article/title | /article/articleinfo/title"/></h1>

        <!-- begin toc -->
        <div class="toc">
            <span class="toc-item">
                <a name="toc"><a href="{$request.uri}?section-view=true;">Table of Contents</a></a>
            </span>
            <xsl:apply-templates select="./section[position()=$section]" mode="toc"/>
        </div>
        <!-- end toc -->

        <!-- begin main content -->
        <div class="main-content">
            <xsl:apply-templates select="./section[position()=$section]"/>
        </div>
        <!-- end main content -->

        <!-- begin footer -->
        <xsl:call-template name="sdbkfooter"/>
        <!-- end footer -->
    </xsl:template>

    <xsl:template match="section">
        <div class="section">
            <xsl:attribute name="id">
                <xsl:choose>
                    <xsl:when test="@label">
                        <xsl:value-of select="@label"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="translate(title, '' -)(?:
'', '''')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <xsl:element name="h{number( count(ancestor-or-self::section) + 1)}">
                <a name="{translate(title, '' -)(?:
'', '''')}">
                    <xsl:value-of select="title"/>
                </a>
            </xsl:element>

            <xsl:apply-templates/>

            <xsl:if test=" count(parent::section) = 0">
                <p>
                    [
                    <a href="#toc">
                        top
                    </a>
                    ]
                </p>
            </xsl:if>

        </div>
    </xsl:template>

    <xsl:template match="section" mode="toc">
        <div class="toc-item" id="{generate-id()}">
            <xsl:choose>
                <xsl:when test="$section-view=''true''">
                    <xsl:choose>
                        <xsl:when test="count(ancestor-or-self::section) = 1">
                            <xsl:variable name="page-number" select="count(preceding-sibling::section) + 1"/>

                            <!-- begin TOC page (section 0) for multi-page mode -->
                            <xsl:if test="$section-view=''true'' and $section = 0">

                                <!-- <a href="{$request.uri}?section-view=true;section={count(preceding-sibling::section) +1}"> -->
                                <a href="{$request.uri}?section-view=true;section={$page-number};">
                                    <xsl:value-of select="title"/>
                                </a>
                            </xsl:if>
                            <!-- end TOC page (section 0) for multi-page mode -->

                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="page-number" select="count(ancestor::section[count(ancestor-or-self::section) = 1]/preceding-sibling::section) + 1"/>
                            <a href="{$request.uri}?section-view=true;section={$page-number};#{translate(title, '' -)(?:
'', '''')}">
                                <xsl:value-of select="title"/>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <a href="#{translate(title, '' -)(?:
'', '''')}">
                        <xsl:value-of select="title"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="section" mode="toc"/>
        </div>
    </xsl:template>


    <!-- begin named XSL templates -->

    <!-- begin footer template -->
    <xsl:template name="sdbkfooter">
        <xsl:if test="$section-view=''true''">
            <div class="footer-nav">
                <!-- it sucks that we have to use a table here but CSS is still a "future technology" i guess :-( -->
                <table width="100%" border="0" cellpadding="2" cellspacing="0">
                    <tr valign="top">
                        <td>
                            <xsl:choose>
                                <xsl:when test="$section &gt; 0">Prev:
                                    <a href="{$request.uri}?section={$section -1};section-view=true">
                                        <xsl:choose>
                                            <xsl:when test="/article/section[$section -1]">
                                                <xsl:value-of select="/article/section[$section -1]/title"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>Table of Contents</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                     
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td align="right">
                            <xsl:choose>
                                <xsl:when test="/article/section[$section +1]">
                                Next: <a href="{$request.uri}?section={$section +1};section-view=true;">
                                        <xsl:value-of select="/article/section[$section +1]/title"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                     
                                </xsl:otherwise>
                            </xsl:choose>
                        </td></tr>
                </table>
            </div>
        </xsl:if>
        <div class="legal">
            <xsl:choose>
                <xsl:when test="/article/articleinfo/legalnotice">
                    <xsl:apply-templates select="/article/articleinfo/legalnotice/*"/>
                </xsl:when>
                <xsl:otherwise>
                    <p/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!-- end footer template -->

    <!-- end named XSL templates -->

    <!-- begin core sdocbook elements -->
    <xsl:template match="para">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="itemizedlist">
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="orderedlist">
        <ol>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>

    <xsl:template match="listitem">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="ulink">
        <a href="{@url}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="xref|link">
        <a href="#{@linkend}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!-- seems correct for sdocbook -->
    <xsl:template match="email">
      <a href="mailto:{.}">
            <xsl:value-of select="."/>
      </a>
    </xsl:template>

    <xsl:template match="programlisting">
        <div class="programlisting">
            <pre>
                <xsl:apply-templates/>
            </pre>
        </div>
    </xsl:template>

    <xsl:template match="filename | userinput | computeroutput | literal">
        <code>
            <xsl:apply-templates/>
        </code>
    </xsl:template>

    <xsl:template match="literallayout">
        <pre>
            <xsl:apply-templates/>
        </pre>
    </xsl:template>

    <xsl:template match="emphasis">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

    <xsl:template match="blockquote">
        <blockquote>
            <xsl:apply-templates/>
        </blockquote>
    </xsl:template>

    <xsl:template match="inlinemediaobject">
        <span class="mediaobject">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="mediaobject">
        <div class="mediaobject">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="imageobject">
        <img src="{imagedata/@fileref}"/>
    </xsl:template>

    <xsl:template match="caption">
        <div class="{name(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="note|important|warning|caution|tip">
        <div class="{name(.)}">
            <h3 class="title">
                <a>
                    <xsl:attribute name="name">
                        <xsl:call-template name="object.id"/>
                    </xsl:attribute>
                </a>
                <xsl:value-of select="concat(translate(substring(name(.),1,1),''niwct'',''NIWCT''),substring(name(.),2,string-length(name(.)-1)))"/>
            </h3>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!--the following is a slightly adapted excerpt of Norman Walsh''s table.xsl -->

    <xsl:template match="table">
        <xsl:apply-templates select="tgroup"/>
    </xsl:template>

    <xsl:template match="tgroup">
        <table>
        <xsl:if test="../@pgwide=1">
            <xsl:attribute name="width">100%</xsl:attribute>
        </xsl:if>
        <xsl:attribute name="border">0</xsl:attribute>

        <xsl:apply-templates select="thead"/>
        <xsl:apply-templates select="tbody"/>
        <xsl:apply-templates select="tfoot"/>

        <xsl:if test=".//footnote">
            <tbody class="footnotes">
                <tr>
                    <td colspan="{@cols}">
                        <xsl:apply-templates select=".//footnote" mode="table.footnote.mode"/>
                    </td>
                </tr>
            </tbody>
        </xsl:if>
        </table>
    </xsl:template>

    <xsl:template match="colspec"/>

    <xsl:template match="spanspec"/>

    <xsl:template match="thead|tfoot">
        <xsl:element name="{name(.)}">
            <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@char">
                <xsl:attribute name="char">
                    <xsl:value-of select="@char"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@charoff">
                <xsl:attribute name="charoff">
                    <xsl:value-of select="@charoff"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="valign">
                    <xsl:value-of select="@valign"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tbody">
        <tbody>
            <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@char">
                <xsl:attribute name="char">
                    <xsl:value-of select="@char"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@charoff">
                <xsl:attribute name="charoff">
                    <xsl:value-of select="@charoff"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="valign">
                    <xsl:value-of select="@valign"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>

    <xsl:template match="row">
        <tr>
            <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@char">
                <xsl:attribute name="char">
                    <xsl:value-of select="@char"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@charoff">
                <xsl:attribute name="charoff">
                    <xsl:value-of select="@charoff"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="valign">
                    <xsl:value-of select="@valign"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="thead/row/entry">
        <xsl:call-template name="process.cell">
            <xsl:with-param name="cellgi">th</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="tbody/row/entry">
        <xsl:call-template name="process.cell">
            <xsl:with-param name="cellgi">td</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="tfoot/row/entry">
        <xsl:call-template name="process.cell">
            <xsl:with-param name="cellgi">th</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="process.cell">
        <xsl:param name="cellgi">td</xsl:param>
        <xsl:variable name="empty.cell" select="count(node()) = 0"/>
        <xsl:variable name="entry.colnum">
            <xsl:call-template name="entry.colnum"/>
        </xsl:variable>

        <xsl:if test="$entry.colnum != ''''">
            <xsl:variable name="prev.entry" select="preceding-sibling::*[1]"/>
            <xsl:variable name="prev.ending.colnum">
                <xsl:choose>
                    <xsl:when test="$prev.entry">
                        <xsl:call-template name="entry.ending.colnum">
                            <xsl:with-param name="entry" select="$prev.entry"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

        </xsl:if>

        <xsl:element name="{$cellgi}">
            <xsl:if test="@morerows">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="@morerows+1"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@namest">
                <xsl:attribute name="colspan">
                    <xsl:call-template name="calculate.colspan"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@char">
                <xsl:attribute name="char">
                    <xsl:value-of select="@char"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@charoff">
                <xsl:attribute name="charoff">
                    <xsl:value-of select="@charoff"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
                <xsl:attribute name="valign">
                    <xsl:value-of select="@valign"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="class">orange</xsl:attribute>
            <xsl:choose>
                <xsl:when test="$empty.cell">
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template name="entry.colnum">
        <xsl:param name="entry" select="."/>

        <xsl:choose>
            <xsl:when test="$entry/@colname">
                <xsl:variable name="colname" select="$entry/@colname"/>
                <xsl:variable name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$colname]"/>
                <xsl:call-template name="colspec.colnum">
                    <xsl:with-param name="colspec" select="$colspec"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entry/@namest">
                <xsl:variable name="namest" select="$entry/@namest"/>
                <xsl:variable name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$namest]"/>
                <xsl:call-template name="colspec.colnum">
                    <xsl:with-param name="colspec" select="$colspec"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count($entry/preceding-sibling::*) = 0">1</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="pcol">
                    <xsl:call-template name="entry.ending.colnum">
                        <xsl:with-param name="entry" select="$entry/preceding-sibling::*[1]"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$pcol + 1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="entry.ending.colnum">
        <xsl:param name="entry" select="."/>

        <xsl:choose>
            <xsl:when test="$entry/@colname">
                <xsl:variable name="colname" select="$entry/@colname"/>
                <xsl:variable name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$colname]"/>
                <xsl:call-template name="colspec.colnum">
                    <xsl:with-param name="colspec" select="$colspec"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entry/@nameend">
                <xsl:variable name="nameend" select="$entry/@nameend"/>
                <xsl:variable name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$nameend]"/>
                <xsl:call-template name="colspec.colnum">
                    <xsl:with-param name="colspec" select="$colspec"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count($entry/preceding-sibling::*) = 0">1</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="pcol">
                    <xsl:call-template name="entry.ending.colnum">
                        <xsl:with-param name="entry" select="$entry/preceding-sibling::*[1]"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$pcol + 1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="colspec.colnum">
        <xsl:param name="colspec" select="."/>
        <xsl:choose>
            <xsl:when test="$colspec/@colnum">
                <xsl:value-of select="$colspec/@colnum"/>
            </xsl:when>
            <xsl:when test="$colspec/preceding-sibling::colspec">
                <xsl:variable name="prec.colspec.colnum">
                    <xsl:call-template name="colspec.colnum">
                        <xsl:with-param name="colspec" select="$colspec/preceding-sibling::colspec[1]"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$prec.colspec.colnum + 1"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="calculate.colspan">
        <xsl:param name="entry" select="."/>
        <xsl:variable name="namest" select="$entry/@namest"/>
        <xsl:variable name="nameend" select="$entry/@nameend"/>

        <xsl:variable name="scol">
            <xsl:call-template name="colspec.colnum">
                <xsl:with-param name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$namest]"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ecol">
            <xsl:call-template name="colspec.colnum">
                <xsl:with-param name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$nameend]"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$ecol - $scol + 1"/>
    </xsl:template>

    <!--table.xsl end-->

    <!--the "css forwarder" template
    These are the sdocbook elements
    for which there is no reasonable
    HTML counterpart structure but to
    which a designer may want to add some
    visual distiction via CSS -->

    <xsl:template match="authorinitials">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!--the "vanilla" template
    these are the sdocbook elements
    for which there is no reasonable
    HTML counterpart or straightforward
    meaningful visual format -->

    <xsl:template match="honorific">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="title"/>
    <!-- end core sdocbook elements -->

    <!-- this is from footnote.xsl -->

    <xsl:template match="footnote">
        <xsl:variable name="name">
            <xsl:call-template name="object.id"/>
        </xsl:variable>
        <xsl:variable name="href">
            <xsl:text>#ftn.</xsl:text>
            <xsl:call-template name="object.id"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="ancestor::table|ancestor::informaltable">
                <sup>
                    <xsl:text>[</xsl:text>
                    <a name="{$name}" href="{$href}">
                        <xsl:apply-templates select="." mode="footnote.number"/>
                    </a>
                    <xsl:text>]</xsl:text>
                </sup>
            </xsl:when>
            <xsl:otherwise>
                <sup>
                    <xsl:text>[</xsl:text>
                    <a name="{$name}" href="{$href}">
                        <xsl:apply-templates select="." mode="footnote.number"/>
                    </a>
                    <xsl:text>]</xsl:text>
                </sup>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="footnoteref">
        <xsl:variable name="targets" select="id(@linkend)"/>
        <xsl:variable name="footnote" select="$targets[1]"/>
        <xsl:variable name="href">
            <xsl:text>#ftn.</xsl:text>
            <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="$footnote"/>
            </xsl:call-template>
        </xsl:variable>
        <sup>
            <xsl:text>[</xsl:text>
            <a href="{$href}">
                <xsl:apply-templates select="$footnote" mode="footnote.number"/>
            </a>
            <xsl:text>]</xsl:text>
        </sup>
    </xsl:template>

    <xsl:template match="footnote" mode="footnote.number">
        <xsl:choose>
            <xsl:when test="ancestor::table|ancestor::informaltable">
                <xsl:number level="any" from="table|informaltable" format="a"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" format="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ==================================================================== -->

    <xsl:template match="footnote/para[1]">
        <!-- this only works if the first thing in a footnote is a para, -->
        <!-- which is ok, because it usually is. -->
        <xsl:variable name="name">
            <xsl:text>ftn.</xsl:text>
            <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="ancestor::footnote"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="href">
            <xsl:text>#</xsl:text>
            <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="ancestor::footnote"/>
            </xsl:call-template>
        </xsl:variable>
        <p>
            <sup>
                <xsl:text>[</xsl:text>
                <a name="{$name}" href="{$href}">
                    <xsl:apply-templates select="ancestor::footnote" mode="footnote.number"/>
                </a>
                <xsl:text>] </xsl:text>
            </sup>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- ==================================================================== -->

    <xsl:template name="process.footnotes">
        <xsl:variable name="footnotes" select=".//footnote"/>
        <xsl:variable name="table.footnotes" select=".//table//footnote|.//informaltable//footnote"/>

        <!-- Only bother to do this if there''s at least one non-table footnote -->
        <xsl:if test="count($footnotes)&gt;count($table.footnotes)">
            <div class="footnotes">
                <br/>
                <xsl:apply-templates select="$footnotes" mode="process.footnote.mode"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="process.chunk.footnotes">
        <!-- nop -->
    </xsl:template>

    <xsl:template match="footnote" mode="process.footnote.mode">
        <div class="{name(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="informaltable//footnote|table//footnote" mode="process.footnote.mode">
    </xsl:template>

    <xsl:template match="footnote" mode="table.footnote.mode">
        <div class="{name(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- this was from footnote.xsl -->

    <!-- this was from common.xsl -->

    <xsl:template name="object.id">
        <xsl:param name="object" select="."/>
        <xsl:choose>
            <xsl:when test="$object/@id">
                <xsl:value-of select="$object/@id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id($object)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- this was from common.xsl -->

</xsl:stylesheet>
');

-- add XSL-T stylesheet 'error.xsl' to 'stylesheets'-folder in 'xims' # doc_id=28
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 21, 7, 3, 2, 'error.xsl', 7, '/xims/stylesheets/error.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 28, 'error.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/xhtml1/strict" version="1.0">
    <xsl:output method="html" encoding="ISO-8859-1"/>

    <xsl:template match="bt">

        <tr>
            <xsl:if test="position() mod 2">
                <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
            </xsl:if>
            <td>
                <xsl:value-of select="@level"/>
            </td>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="file|line">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="/">
        <html>
            <head>
                <title>Server Error</title>
                <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css"/>
            </head>
            <body>
                <h1>Server Error</h1>
                <p>The following error occurred: <xsl:value-of select="/error/msg"/></p>
                <h2>Stack Trace:</h2>
                <table>
                    <tr bgcolor="blue"><th>Level</th><th>File</th><th>Line #</th></tr>

                    <xsl:apply-templates select="/error/stack_trace/*"/>

                </table>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
');

-- add CSS stylesheet 'default.css' to 'stylesheets'-folder in 'xims' # doc_id=29
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 21, 21, 5, 2, 'default.css', 8, '/xims/stylesheets/default.css');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 29, 'default.css', 2, 2, 2, 2, 'body, html, div {
    margin: 0;
    padding: 0;
}


body {
    font: 10pt/16pt helvetica, arial, sans-serif;
}

h1, h2, h3, h4, h5, h6 {
    border-bottom: 1px solid #eeeeee;
    text-align: justify;
    color:#336633;
}

h1 {
    font: bolder 16pt/16pt helvetica, arial, sans-serif;
    margin-top:10px;
    margin-bottom:20px;
}

h2 {
    font: bolder 14pt/14pt verdana, geneva, arial, sans serif;
}

h3 {
    font: bolder 12pt/12pt verdana, geneva, arial, sans serif;
}

p {
    font: 10pt/14pt helvetica, arial, sans-serif;
    text-align: justify;
    margin-bottom: 8pt;
    margin-top: 8pt;
}

.emphasis {
    font: italic bold 10pt/12pt helvetica, arial, sans-serif;
    margin-left:15px;
    margin-right:15px;
}

#footer .left {
    float: left;
    position: relative;
    margin: 0px;
    padding: 0px;
    top: 23px;
}

.right {
    float: right;
}

a:link {
    color: #ff6600;
    text-decoration:none;
}

a:visited {
    color: #cc3300;
    text-decoration:none;
}

a:hover {
    color: #000000;
    text-decoration:underline;
}

#header {
    background:#fff;
    height:40px;
    border-top:1px;
    border-right:1px;
    border-left:1px;
    voice-family: &quot;\\&quot;}\\&quot;&quot;;
    voice-family: inherit;
    height:39px;
    width:790px;
}

#banner {
    background: url(http://xims.info/images/header_bg.png) repeat-x;
}

#logo {
    position: absolute;
    top: 0px;
    left: 622px;;
}

#pathnavigation {
    position: absolute;
    top: 45px;
    left:1px;
    background: #ffffff;
    border-bottom: 1px solid #BACFB2;
    width: 790px;
}

#pathnavigation a {
    text-decoration:none;
}

#pathnavigation a:link {
    color: #ff6600;
}

#pathnavigation a:visited {
    color: #ff6600;
}

#pathnavigation a:hover {
    color: #ffaa44;
}

#leftcontent {
    position: absolute;
    left:3px;
    top:80px;
    width:145px;
    background:#fff;
}

#centercontent {
    position: absolute;
    left:160px;
    top:80px;
    width:630px;
}

#footer {
    margin-top: 50px;
    font: 7pt/7pt helvetica, arial, sans-serif;
    color: #a9a9a9;
}

#linkbox {
    margin-bottom: 5px;
    padding-top:13px;
    padding-left:4px;
    padding-right:4px;
    padding-bottom:8px;
    width:135px;
    background: url(http://xims.info/images/linkbox_tl.png) no-repeat top left;
    background-color:#FFFFFF;
    border: 1px solid #F5BB95;
}

#linkbox h3 {
    font: bold 8pt/8pt helvetica, arial, sans-serif;
    margin: 0 0 0 5px;
    padding: 0;
    border: 0;
    color:#669933;
}

#linkbox ul {
    list-style:none;
    margin: 1px 0 0 0;
    padding: 0;
}

#linkbox li {
    background:  url(http://xims.info/images/bullet.png) no-repeat 2px 3px;
    margin-left:5px;
    padding: 0 0 0 15px;
}

#linkbox li a:hover {
    padding-left: 1px;
    padding-right: 4px;
    text-decoration: none;
    background: #E3F0D2;
    border-left: 1px solid #669933;
    border-bottom: 1px solid #669933;
}

#linkbox a:link {
    color: #000000;
}

#linkbox a:visited {
    color: #000000;
}

#departmentlinks {
    margin-bottom: 5px;
    padding-top:13px;
    padding-left:4px;
    padding-right:4px;
    padding-bottom:8px;
    background-color:#F4F8EF;
    border: 1px solid #C9EBA7;
    background: url(http://xims.info/images/departmentlinks_tl.png) no-repeat top left;
    background-color:#F4F8EF;
    border: 1px solid #C9EBA7;
    width:135px;
}

#departmentlinks h3 {
    font: bold 8pt/8pt helvetica, arial, sans-serif;
    margin: 0 0 0 5px;
    padding: 0;
    border: 0;
    color:#ff6600;
}

#departmentlinks ul {
    list-style:none;
    margin: 1px 0 0 0;
    padding: 0;
}

#departmentlinks li {
    background: url(http://xims.info/images/bullet.png) no-repeat 2px 3px;
    margin-left:5px;
    padding: 0 0 0px 15px;
}

#departmentlinks li a:hover {
    padding-left: 1px;
    padding-right: 4px;
    text-decoration: none;
    background: #F3C7AB;
    border-left: 1px solid #DF7900;
    border-bottom: 1px solid #DF7900;
}

#departmentlinks a:link {
    color: #000000;
    text-decoration:none;
}

#departmentlinks a:visited {
    color: #000000;
}

#newsbox {
    margin-top: 5px;
    padding-top:13px;
    padding-left:4px;
    padding-right:4px;
    padding-bottom:8px;
    width:135px;
    background: url(http://xims.info/images/newsbox_tl.png) no-repeat top left;
    background-color:#FFFFFF;
    border: 1px solid #F5BB95;
}

#newsbox h3 {
    font: bold 8pt/8pt helvetica, arial, sans-serif;
    margin: 0 0 0 5px;
    padding: 0;
    border: 0;
    color:#669933;
}

#newsbox ul {
    list-style:none;
    margin: 1px 0 0 0;
    padding: 0;
}

#newsbox li {
    background:  url(http://xims.info/images/bullet.png) no-repeat 2px 3px;
    font: 8pt/10pt helvetica, arial, sans-serif;
    margin-left:5px;
    margin-top:3px;
    padding: 0 0 0 15px;
}

#newsbox li a:hover {
    padding-left: 1px;
    padding-right: 4px;
    text-decoration: none;
    background: #E3F0D2;
    border-left: 1px solid #669933;
    border-bottom: 1px solid #669933;
}

#newsbox a:link {
    color: #000000;
}

#newsbox a:visited {
    color: #000000;
}

#searchform {
}

#searchform input {
    font-face: helvetica;
    font-size: 10pt;
}

#searchform .inputtext {
    background: #eeeeee;
}

#searchform .inputsubmit:hover {
    background: #AAD372;
    border: 1px dotted black;
}

#searchresults {
}

#searchresults .searchresultitem {
    border-bottom: 1px solid #808080;
    padding-top: 5px;
    padding-bottom: 10px;
}

#searchresults .title {
    padding-left: 4px;
}

#searchresults .location_path, .meta {
    line-height: 12px;
    margin: 0px;
    font-size: 8pt;
    color: #000000;
    padding-left: 40px;
}

#searchresults .abstract {
    font-size: 9pt;
    color: #808080;
    padding-left: 40px;
}
');

-- add Folder 'include' in folder 'stylesheets' of 'xims' SiteRoot # doc_id=30
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 21, 1, 18, 2, 'include', 9, '/xims/stylesheets/include');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id )
	VALUES (nextval('ci_content_id_seq'), 30, 'include', 2, 2, 2, 2);

-- add XSL-T stylesheet 'common.xsl' to 'include'-folder in 'stylesheets' # doc_id=31
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 30, 7, 3, 2, 'common.xsl', 1, '/xims/stylesheets/include/common.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 31, 'common.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">

<!--$Id: common.xsl 1656 2007-04-26 11:57:59Z pepl $-->
<xsl:import href="common-generic.xsl"/>

<xsl:template name="stdlinks">
    <div id="linkbox">
        <h3>xims.info</h3>
        <ul>
            <li title="Home"><a href="http://xims.info/">Home</a></li>
            <li title="About"><a href="http://xims.info/about.html">About</a></li>
            <li title="Documentation"><a href="http://xims.info/documentation/">Documentation</a></li>
            <li title="Screenshots"><a href="http://xims.info/screenshots/">Screenshots</a></li>
            <li title="Presentations"><a href="http://xims.info/presentations/">Presentations</a></li>
            <li title="Download"><a href="http://xims.info/download/">Download</a></li>
            <li title="Login"><a href="/goxims/user">Login</a></li>
        </ul>
    </div>
</xsl:template>

<xsl:template name="copyfooter">
    © 2002-2011 <a href="http://xims.info/">The XIMS Project</a>
</xsl:template>

<xsl:template name="powerdbyfooter">
    Powered by <a href="http://axkit.org/"><img src="http://xims.info/images/powered_by_axkit_wbg.gif" width="96" height="31" alt="Powered by AxKit" title="Powered by AxKit" border="0"/></a>
    <xsl:text> &amp; </xsl:text>
    <a href="http://sourceforge.net">
        <img src="http://sourceforge.net/sflogo.php?group_id=42250" width="88" height="31" border="0" alt="SourceForge Logo"/>
    </a>
</xsl:template>

</xsl:stylesheet>
');

-- add XSL-T stylesheet 'common-generic.xsl' to 'include'-folder in 'stylesheets' # doc_id=32
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 30, 7, 3, 2, 'common-generic.xsl', 2, '/xims/stylesheets/include/common-generic.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 32, 'common-generic.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcq="http://purl.org/dc/qualifiers/1.0/" version="1.0">

<!--$Id: common-generic.xsl 1518 2006-06-21 22:20:23Z pepl $-->
<xsl:param name="request.uri.query"/>
<xsl:param name="request.uri"/>

<xsl:template match="abbr|acronym|address|b|bdo|big|blockquote|br|cite|code|div|del|dfn|em|hr|h1|h2|h3|h4|h5|h6|i|ins|kbd|p|pre|q|samp|small|span|strong|sub|sup|tt|var|         dl|dt|dd|li|ol|ul|         a|         img|map|area|         caption|col|colgroup|table|tbody|td|tfoot|th|thead|tr|         button|fieldset|form|label|legend|input|option|optgroup|select|textarea|         applet|object|param|embed|script">
    <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
        <xsl:for-each select="@*">
            <xsl:attribute name="{name(.)}">
                <xsl:value-of select="."/>
            </xsl:attribute>
        </xsl:for-each>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>


<xsl:template name="meta">
      <xsl:param name="context_node" select="."/>
      <link rel="schema.DC" href="http://purl.org/DC/elements/1.0/"/>
      <meta name="DC.Title" content="{$context_node/rdf:RDF/rdf:Description/dc:title}"/>
      <meta name="DC.Creator" content="{$context_node/rdf:RDF/rdf:Description/dc:creator}"/>
      <meta name="DC.Subject" content="{$context_node/rdf:RDF/rdf:Description/dc:subject}"/>
      <meta name="DC.Description" content="{$context_node/rdf:RDF/rdf:Description/dc:description}"/>
      <meta name="DC.Publisher" content="{$context_node/rdf:RDF/rdf:Description/dc:publisher}"/>
      <meta name="DC.Contributor" content="{$context_node/rdf:RDF/rdf:Description/dc:contributor}"/>
      <meta name="DC.Date.Created" scheme="{$context_node/rdf:RDF/rdf:Description/dc:date/dcq:created/rdf:Description/dcq:dateScheme}" content="{$context_node/rdf:RDF/rdf:Description/dc:date/dcq:created/rdf:Description/rdf:value}"/>
      <meta name="DC.Date.Modified" scheme="{$context_node/rdf:RDF/rdf:Description/dc:date/dcq:modified/rdf:Description/dcq:dateScheme}" content="{$context_node/rdf:RDF/rdf:Description/dc:date/dcq:modified/rdf:Description/rdf:value}"/>
      <meta name="DC.Format" content="{$context_node/rdf:RDF/rdf:Description/dc:format}"/>
      <meta name="DC.Language" content="{$context_node/rdf:RDF/rdf:Description/dc:language}"/>
      <!-- for compatibility -->
      <meta name="keywords" content="{$context_node/rdf:RDF/rdf:Description/dc:subject}"/>
</xsl:template>

<xsl:template name="pathnavigation">
    <xsl:param name="string" select="$request.uri"/>
    <xsl:param name="pattern" select="''/''"/>

    <xsl:choose>
        <xsl:when test="contains($string, $pattern)">
            <xsl:if test="not(starts-with($string, $pattern))">
                <xsl:call-template name="pathnavigation">
                   <xsl:with-param name="string" select="substring-before($string, $pattern)"/>
                   <xsl:with-param name="pattern" select="$pattern"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="pathnavigation">
                <xsl:with-param name="string" select="substring-after($string, $pattern)"/>
                <xsl:with-param name="pattern" select="$pattern"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$string = ''_ottereendex.html''">
                     /
                </xsl:when>
                <xsl:when test="contains($request.uri, concat($string,''/''))">
                     / <a><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''''"><xsl:value-of select="concat(substring-before($request.uri, concat($string,''/'')),$string,''/'')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat(substring-before($request.uri, concat($string,''/'')),$string,''/'',''?'',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="$string"/></a>
                </xsl:when>
                <xsl:otherwise>
                     / <a><xsl:attribute name="href"><xsl:choose><xsl:when test="$request.uri.query = ''''"><xsl:value-of select="$request.uri"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($request.uri, ''?'',$request.uri.query)"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="$string"/></a>
                </xsl:otherwise>
            </xsl:choose>
       </xsl:otherwise>
     </xsl:choose>
</xsl:template>

<xsl:template name="departmentlinks">
    <xsl:param name="context" select="."/>
    <xsl:if test="$context/ou/portlet[title = ''departmentlinks_portlet'']/portlet-item">
        <div id="departmentlinks">
            <h3>DepartmentLinks</h3>
            <ul>
                 <xsl:apply-templates select="$context/ou/portlet[title = ''departmentlinks_portlet'']/portlet-item">
                    <xsl:sort select="position" data-type="number" order="ascending"/>
                 </xsl:apply-templates>
            </ul>
        </div>
  </xsl:if>
</xsl:template>

<xsl:template match="portlet-item">
    <li>
        <a>
            <xsl:attribute name="href"><xsl:value-of select="location"/></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="abstract"/></xsl:attribute>
            <xsl:value-of select="title"/>
        </a>
    </li>
</xsl:template>

<xsl:template match="portlet-item" mode="print">
    <li>
        <a>
            <xsl:attribute name="href"><xsl:value-of select="location"/><xsl:if test="$request.uri.query != ''''">?<xsl:value-of select="$request.uri.query"/></xsl:if></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="abstract"/></xsl:attribute>
            <xsl:value-of select="title"/>
        </a>
    </li>
</xsl:template>

<xsl:template name="documentlinks">
  <xsl:param name="mode" select="default"/>
    <xsl:if test="links/link">
        <div id="linkbox">
            <h3>DocumentLinks</h3>
            <ul>
                <xsl:apply-templates select="links"/>
            </ul>
        </div>
  </xsl:if>
</xsl:template>

<xsl:template match="link">
    <li>
        <a href="{@href}"><xsl:value-of select="@title"/></a>
    </li>
</xsl:template>

</xsl:stylesheet>
');

-- add XSL-T stylesheet 'default_header.xsl' to 'include'-folder in 'stylesheets' # doc_id=33
INSERT INTO ci_documents ( id, parent_id, object_type_id, data_format_id, department_id, location, position, location_path )
	VALUES (nextval('ci_documents_id_seq'), 30, 7, 3, 2, 'default_header.xsl', 3, '/xims/stylesheets/include/default_header.xsl');
INSERT INTO ci_content ( id, document_id, title, language_id, last_modified_by_id, owned_by_id, created_by_id, body )
	VALUES (nextval('ci_content_id_seq'), 33, 'default_header.xsl', 2, 2, 2, 2, '<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
<!--$Id: default_header.xsl 483 2004-02-20 10:30:56Z pepl $-->
<xsl:template name="header">
    <div id="header">
        <div id="pathnavigation">
             <xsl:call-template name="pathnavigation"/>
        </div>
        <div id="banner">
            <img src="http://xims.info/ximspubroot/images/header_the_extensible.png" width="233" height="45" alt="The eXtensible Information Management System" title="The eXtensible Information Management System"/>
            <div id="logo">
                <a href="/"><img src="http://xims.info/ximspubroot/images/header_logo.png" width="168" height="65" alt="XIMS Logo" title="Go to the XIMS Homepage" border="0"/></a>
            </div>
        </div>
    </div>
</xsl:template>
</xsl:stylesheet>
');

-- end of default data content
