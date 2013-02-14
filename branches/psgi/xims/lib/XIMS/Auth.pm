
=head1 NAME

XIMS::Auth -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Auth;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Auth;

use common::sense;
use XIMS;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 new()

=cut

sub new {
    XIMS::Debug( 5, "called" );
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless { Username => $args{Username}, Password => $args{Password} }, $class;
    return $self ;
}

=head2 authenticate()

=head3 Returns

 Returns an instance of XIMS::User

=cut

sub authenticate {
    use Data::Dumper;
    #warn Dumper(\@_);
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
 
    my $username = $args{Username} || $self->{Username};
    my $password = $args{Password} || $self->{Password};
    return unless ( $username and $password );

    my @authmods = split(',', XIMS::AUTHSTYLE());
    foreach my $authmod ( @authmods ) {
        XIMS::Debug( 6, "trying authstyle: $authmod" );
        eval "require $authmod;";
        if ( $@ ) {
            XIMS::Debug( 2, "could not load authmod $authmod! reason: $@" );
        }
        else {
            my $login = $authmod->new(  Server   => XIMS::AUTHSERVER(),
                                        Login    => $username,
                                        Password => $password );
            if ( $login ) {
                XIMS::Debug( 4, "login with authstyle $authmod ok" );
                #return $login->getUserInfo();
                return $login;
            }
            else {
                XIMS::Debug( 4, "login with authstyle $authmod failed" );
            }
        }
    }
    XIMS::Debug( 3, "login failed!" );
    return;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<ximsconfig.xml>: select AuthStyle

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

