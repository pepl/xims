
=head1 NAME

XIMS::SAX::Filter::UserIDNameResolver -- expands a user id to its
corresponding name

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::UserIDNameResolver;

=head1 DESCRIPTION

This SAX Filter expands a user id to its corresponding name.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::UserIDNameResolver;

use strict;
use parent qw( XIMS::SAX::Filter::DataCollector );
use XIMS::User;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 new()

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    return $self;
}

=head2 start_element()

=cut

sub start_element {
    my ( $self, $element ) = @_;

    if ( defined $element->{LocalName}
        and grep {/^$element->{LocalName}$/i} @{ $self->{ResolveUser} } )
    {
        $self->{got_to_resolve} = 1;
    }

    $self->SUPER::start_element($element);

    return;
}

=head2 end_element()

=cut

sub end_element {
    my $self = shift;

    if (    defined $self->{got_to_resolve}
        and defined $self->{user_id}
        and $self->{user_id} =~ /^[0-9]+$/ )
    {
        my $name = XIMS::User->new( id => $self->{user_id} )->name();
        $self->SUPER::characters( { Data => $name } );
        $self->{user_id} = undef;
    }

    $self->{got_to_resolve} = undef;
    $self->SUPER::end_element(@_);

    return;
}

=head2 characters()

=cut

sub characters {
    my ( $self, $string ) = @_;

    if (    defined $string->{Data}
        and defined $self->{got_to_resolve}
        and $self->{got_to_resolve} == 1 )
    {
        $self->{user_id} .= $string->{Data};
    }
    else {
        $self->SUPER::characters($string);
    }

    return;
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

