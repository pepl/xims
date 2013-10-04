
=head1 NAME

XIMS::SAX::Generator::Users -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Generator::Users;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Generator::Users;

use common::sense;
use parent qw(XIMS::SAX::Generator XML::Generator::PerlData);




=head2    $generator->prepare( $ctxt );

=head3 Parameter

    $ctxt : the appcontext object

=head3 Returns

    $doc_data : hash ref to be given to be mangled by XML::Generator::PerlData

=head3 Description



=cut

sub prepare {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    $self->{FilterList} = [];

    my $doc_data = { context => {} };
    $doc_data->{context}->{session} = {$ctxt->session->data()};
    $doc_data->{context}->{session}->{user} = {$ctxt->session->user->data()};

    # add the user's system privs.
    $doc_data->{context}->{session}->{user}->{system_privileges} = {$ctxt->session->user->system_privileges()} if $ctxt->session->user->system_privs_mask() > 0;

    if ( $ctxt->objectlist() ) {
        $doc_data->{objectlist} = { object => $ctxt->objectlist() };
    }

    if ( $ctxt->bookmarklist() ) {
        $doc_data->{bookmarklist} = { bookmark => $ctxt->bookmarklist() };
    }

    if ( $ctxt->objecttypelist() ) {
        $doc_data->{objecttypelist} = { object_type => $ctxt->objecttypelist() };
    }

    if ( $ctxt->userlist() ) {
        # my @user_list = map{ $_->data() ) } @{$ctxt->userlist()};
        $doc_data->{userlist} = { user => $ctxt->userlist() };
    }

    if ( $ctxt->user() ) {
        $doc_data->{context}->{user} = $ctxt->user();
        $doc_data->{context}->{user}->{system_privileges} = {$ctxt->user->system_privileges()} if $ctxt->user->system_privs_mask() > 0;
        $doc_data->{context}->{user}->{dav_otprivileges} = {$ctxt->user->dav_otprivileges()} if $ctxt->user->dav_otprivs_mask() > 0;
        $doc_data->{context}->{user}->{userprefs} = $ctxt->user->userprefs;
        my @object_types = $ctxt->data_provider->object_types();
        $doc_data->{object_types} = { object_type => \@object_types };
    }

    return $doc_data;
}



=head2    $generator->parse( $ctxt );

=head3 Parameter

    $ctxt : the appcontext object

=head3 Returns

    the result of the last Handler after parsing

=head3 Description

Used privately by XIMS::SAX to kick off the SAX event stream.

=cut

sub parse {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my %opts = (@_, $self->get_config);

    $self->parse_start( %opts );

    #warn "about to process: " . Dumper( $ctxt );
    $self->parse_chunk( $ctxt );

    return $self->parse_end;
}



=head2    $generator->get_filters();

=head3 Parameter

    none

=head3 Returns

    @filters : an @array of Filter class names

=head3 Description

Used internally by XIMS::SAX to allow this class to set
additional SAX Filters in the filter chain

=cut

sub get_filters {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @filters =  $self->SUPER::get_filters();

    push @filters, @{$self->{FilterList}};

    return @filters;
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

