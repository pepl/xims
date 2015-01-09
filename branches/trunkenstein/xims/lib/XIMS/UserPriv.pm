
=head1 NAME

XIMS::UserPriv

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::UserPriv;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::UserPriv;

use common::sense;
use parent qw( XIMS::AbstractClass Class::XSAccessor::Compat );

our @Fields = @{XIMS::Names::property_interface_names( resource_type() )};

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

__PACKAGE__->mk_accessors( @Fields );

=head2 new()

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( scalar( keys( %args ) ) > 0 ) {
            my $real_privs = $self->data_provider->getUserPriv( %args );
            if ( defined( $real_privs )) {
               $self->data( %{$real_privs} );
            }
            else {
                return;
            }
        }
        else {
            $self->data( %args );
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

Copyright (c) 2002-2015 The XIMS Project.

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

