
=head1 NAME

XIMS::VLibMeta -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::VLibMeta;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::VLibMeta;

use common::sense;
use parent qw( XIMS::AbstractClass Class::XSAccessor::Compat );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields = @{ XIMS::Names::property_interface_names( resource_type() ) };

=head2 fields()

=cut

sub fields {
    return @Fields;
}

=head2 resource_type()

=cut

sub resource_type {
    my $rt = __PACKAGE__;
    $rt =~ s/.*://;
    return $rt;
}

__PACKAGE__->mk_accessors(@Fields);



=head2    my $meta = XIMS::VLibMeta->new( [ %args ] );

=head3 Parameter

    $args{ id }                  (optional) :  id of an existing VLibMeta object.
    $args{ document_id }         (optional) :  document_id of a VLibraryItem.

=head3 Returns

    $meta    : Instance of XIMS::VLibMeta

=head3 Description

Fetches existing VLibMeta objects or creates a new instance of XIMS::VLibMeta.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args  = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args) ) > 0 ) {
        if ( defined( $args{id} ) or defined( $args{document_id} ) ) {
            my $rt = ref($self);
            $rt =~ s/.*://;
            my $method = 'get' . $rt;
            my $data   = $self->data_provider->$method(%args);
            if ( defined($data) ) {
                $self->data( %{$data} );
            }
            else {
                return;
            }
        }
        else {
            $self->data(%args);
        }
    }
    return $self;
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

Copyright (c) 2002-2011 The XIMS Project.

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

