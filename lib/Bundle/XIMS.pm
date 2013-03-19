package Bundle::XIMS;
# $Id$
## no critic (RequireUseStrict)
our $VERSION = '1.3';

1;
__END__

=head1 NAME

Bundle::XIMS - Modules required to run the XIMS Web-Content Management
System.

=head1 SYNOPSIS

C<perl -MCPAN -e 'install Bundle::XIMS'>

=head1 DESCRIPTION

The bundle provides an easy way to install all of the modules required by
XIMS.

B<Note:> This bundle does not contain the modules that are optional in
XIMS. No DBD::* modules for example.

=head1 CONTENTS

DBI - Database independent interface for Perl
Digest::MD5 -
Storable -
XML::LibXML 1.54 -
XML::LibXSLT 1.49 -
AxKit 1.51 -
AxKit::XSP::Param -
AxKit::XSP::IfParam -
AxKit::XSP::WebUtils 1.6 -
Apache::AxKit::Plugin::AddXSLParams::Request -
XML::Parser::PerlSAX -
XML::SAX::Machines -
XML::Generator::PerlData -
XML::Filter::GenericChunk - 0.04
CGI::XMLApplication 1.1.3 -
Class::Accessor -
DBIx::SQLEngine 0.017 -
Time::Piece -
XML::Schematron -
Apache::DBI -
CSS::Tiny -
Term::ReadKey -
Text::Iconv -
Text::Diff -
DBIx::XHTML_Table -
XML::Generator::DBI -
XML::LibXML::Iterator -
Array::Iterator -
Archive::Zip -
Text::Template -
JavaScript::Minifier::XS -
CSS::Minifier::XS -
MIME::Lite::HTML -
Email::Valid -
Archive::Zip -
File::Slurp -
Locale::TextDomain -

# DBD::Pg 1.31 - PostgreSQL database driver for the DBI module
# Net::LDAP -

=head1 AUTHOR

Michael Kröll <mk@xims.info>

=head1 SEE ALSO

The XIMS home page, at L<http://xims.info/>.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002-2011 The XIMS Project.
See the file L<http://xims.info/license/license-1.0.txt> for information and
conditions for use, reproduction, and distribution of this work,
and for a DISCLAIMER OF ALL WARRANTIES.

=cut
