
=head1 NAME

XIMS::DataFormat -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::DataFormat;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::DataFormat;

use strict;
use base qw( XIMS::AbstractClass Class::Accessor );
use XIMS::MimeType;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields = @{XIMS::Names::property_interface_names( resource_type() )};

sub fields {
    return @Fields;
}

#use Data::Dumper;

sub resource_type {
    return 'DataFormat';
}

__PACKAGE__->mk_accessors( @Fields );

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or defined( $args{mime_type} ) or defined( $args{name} ) or defined( $args{suffix} ) ) {
            my $real_dt = $self->data_provider->getDataFormat( %args );
            if ( defined( $real_dt )) {
               $self->data( %{$real_dt} );
            }
            else {
                # lookup based on alias, is this really needed?
                if ( defined( $args{mime_type} ) ) {
                    my $alias = XIMS::MimeType->new( mime_type => $args{mime_type} );
                    return unless defined( $alias );
                    $real_dt = $self->data_provider->getDataFormat( id => $alias->data_format_id() );
                    return unless defined( $real_dt );
                    $self->data( %{$real_dt} );
                }
                else {
                    return;
                }
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

Copyright (c) 2002-2007 The XIMS Project.

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

