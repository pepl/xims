
=head1 NAME

XIMS::URLLink

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::URLLink;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::URLLink;

use common::sense;
use parent qw( XIMS::Object );
use XIMS::DataFormat;
use LWP::UserAgent;


=head2    XIMS::URLLink->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from ...

=head3 Returns

    $urllink: XIMS::URLLink instance

=head3 Description

Constructor

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'URL' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    XIMS::URLLink->check( [$url, $timeout] )

=head3 Parameter

    $url: optional URL to check. If missing, $object->location() is checked
    $timeout: optional timeout value the http client will use, defaults to 10

=head3 Returns

    $status: 1 if HTTP-Response code begins with 2 or 3
             0 if HTTP-Response code begins with 4 or 5

=head3 Description

Checks the HTTP-Status of the URL-link and stores the result in the object
* status: status code
* status_checked_timestamp: date and time of last check

=cut

sub check {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $url = shift;
    my $timeout = shift;

    $url = $self->location() unless defined $url;
    return unless defined $url;

    my $ua = LWP::UserAgent->new();
    $ua->timeout( $timeout || 10 );

    my $req = HTTP::Request->new( GET => $url );
    my $res = $ua->request( $req );

    XIMS::Debug( 6, "http response status_line: " . $res->status_line() );

    # store status info in object
    $self->status( $res->code() );
    $self->status_checked_timestamp( $self->data_provider->db_now() );

    return 1 if ($res->code() =~ (/^[23]/));
    return 0;
}

=head2    $urllink->update_status( [User => $user] )

=head3 Parameter

    $args{User}: optional XIMS::User instance, defaults to user set at object construction

=head3 Returns

    $boolean: true if updating status was successful
              false if updating status was not successful

=head3 Description

Checks the HTTP Status of the URLLink using check() and updat the object in the database

=cut

sub update_status {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args  = @_;
    my $user = delete $args{User} || $self->{User};

    die "Updating an object requires an associated User"
      unless defined($user);

    if ( not (defined $self->id() and defined $self->location() and length $self->location() ) ) {
        XIMS::Debug( 3, "update_status can only be called on an already created object" );
        return;
    }

    if ( defined $self->check() ) {
        if ( $self->update( User => $user, no_modder => 1 ) ) {
            XIMS::Debug( 4, "Updated status" );
            return 1;
        }
        else {
            XIMS::Debug( 2, "Could not update status for " . $self->id() );
        }
    }
    else {
        XIMS::Debug( 3, "check() did return an undefined value" );
    }

    return
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

