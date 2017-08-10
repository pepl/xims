
=head1 NAME

XIMS::Importer::Object::ReferenceLibraryItem

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::Object::ReferenceLibraryItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::Object::ReferenceLibraryItem;

use common::sense;
use parent qw( XIMS::Importer::Object );
use XIMS::RefLibReferenceProperty;


=head2 check_duplicate_identifier()

=cut

sub check_duplicate_identifier {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $identifier = shift;
    
    my $identifier_property = XIMS::RefLibReferenceProperty->new( name => 'identifier' );
    my @data = $self->data_provider->getRefLibReferencePropertyValue( property_id => $identifier_property->id(), value => $identifier );
    if ( scalar @data ) {
        XIMS::Debug( 3, "ReferenceLibraryItem with same identifier already exists" );
        return;
    }
    else {
        return 1;
    }
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2017 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

