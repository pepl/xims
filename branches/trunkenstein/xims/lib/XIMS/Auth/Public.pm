
=head1 NAME

XIMS::Auth::Public -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id: $

=head1 SYNOPSIS

    use XIMS::Auth::Public;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Auth::Public;

use common::sense;
use XIMS::User;


=head2 new()

=cut

sub new {
    my $class = shift;
    my %param = @_;
    my $self = undef;
    my $user = XIMS::User->new( id =>  XIMS::Config::PublicUserID() );

    if ( $user and $user->enabled() ne '0' ) {
        XIMS::Debug( 4, "user confirmed" );
        $self = bless { User => $user}, $class;
    }
    else {
        XIMS::Debug( 3, "could not authenticate (user may have been disabled)" );
    }
    return $self ;
}

=head2 getUserInfo()

=cut

sub getUserInfo { return $_[0]->{User}; }

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

Copyright (c) 2002-2013 The XIMS Project.

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

