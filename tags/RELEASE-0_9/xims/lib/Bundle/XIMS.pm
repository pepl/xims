package Bundle::XIMS;
# $Id$

our $VERSION = '0.9';

1;
__END__

=head1 NAME

Bundle::XIMS - Modules required to run XIMS content management
system.

=head1 SYNOPSIS

C<perl -MCPAN -e 'install Bundle::XIMS'>

=head1 DESCRIPTION

The bundle provides an easy way to install all of the modules required by
XIMS.

B<Note:> This bundle does not contain the modules that are optional in
XIMS. No DB modules

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
XML::Filter::GenericChunk -
CGI::XMLApplication 1.1.3 -
Class::MethodMaker -
DBIx::SQLEngine 0.017 -
Time::Piece -
XML::Schematron -
Apache::DBI -
CSS::Tiny -
Term::ReadKey -
XML::LibXML::Iterator -

# DBD::Pg 1.31 - PostgreSQL database driver for the DBI module
# Net::LDAP -

=head1 AUTHOR

Michael Kr�ll <michael.kroell@uibk.ac.at>

=head1 SEE ALSO

The XIMS home page, at L<http://xims.info/>.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002-2004 The XIMS Project.
See the file L<http://xims.info/LICENSE> for information on usage and redistribution
of this file, and for a DISCLAIMER OF ALL WARRANTIES.

=cut